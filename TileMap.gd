extends TileMap
#网格AStar寻路脚本，主要功能是返回一个表示最优路径的点的集合

onready var grid_navigation_AStar = self
#字典：方格瓦片ID对应类型名称字典，Grid_Navigation_AStar节点中get_cell()得到的瓦片类型值：方格类型名称
onready var dict_square_type : Dictionary = {
	-1 : "INVALID", #dict_square_type[0]
	0 : "HINDER",
	1 : "PASS"
}
#字典：方格类型名称对应方格权重字典，方格类型名称：权重值
export onready var dict_square_weight : Dictionary = {
	"INVALID" : 100,
	"HINDER" : 50,
	"PASS" : 1
}
#内部类 类：方格 存放网格中一单个的方格信息
class square:
	#声明属性
	#x值表示列，y值表示行
	var x : int
	var y : int
	#方格的类型，由方格当前位置处的瓦片种类决定
	var type : int
	#成本变量F G H
	var G
	var H
	var F
	#父方格，寻路中计算G值使用
	var parent_square : square
	#构造器函数
	func _init(init_x : int, init_y, init_type : int) -> void:
		self.x = init_x
		self.y = init_y
		self.type = init_type
		pass

	#设置父方格
	func set_parent_square(set_parent_square: square):
		self.parent_square = set_parent_square
		pass
	# set G
	func set_G(g: int) ->void:
		self.G = g
		pass
	#计算 H_cost
	func compute_cost_H(destination_square: square) -> int:
		var horizontal_distance : int = abs(x - destination_square.x)
		var vertical_distance : int = abs(y - destination_square.y)
		var H_cost : int
		H_cost = (horizontal_distance + vertical_distance) * 10
		print(H_cost)
		#if horizontal_distance > vertical_distance:
		# H_cost = (horizontal_distance - vertical_distance) * 10 + vertical_distance * 14
		#else:
		# H_cost = (vertical_distance - horizontal_distance) * 10 + horizontal_distance * 14
		return H_cost
		pass
	# set H
	func set_H(h: int) ->void:
		self.H = h
		pass
	#更新 F
	func update_F() -> void:
		self.F = self.G + self.H
		pass
	#函数：依据F值比较大小，目的是作为自定义排序的函数，open_list是Array<square>，
	#可调用 void sort_custom(obj: Object, func: String)
	static func sort_square_by_F(square_a: square, square_b:square) ->bool:
		print("fffff",square_a.F,square_b.F)
		if(square_a.F < square_b.F):
			print(square_a.F,square_b.F)
			return true
		return false
		pass
	#函数：判断一个方格位置是否与当前方格位置相同，主要用以判断是否是目的地方格
	func is_square(compare_square: square) -> bool:
		if(x == compare_square.x && y == compare_square.y):
			return true
		else:
			return false
		pass
	pass
#函数：依据在Grid_Navigation_AStar节点中的位置，得到square类型
func get_square_type_by_xy(x: int,y: int) -> int:
	return grid_navigation_AStar.get_cell(x,y)
	pass
#函数：依据方格类型判断得出一个方格的权重
func get_square_W_by_square_type(square_type : int) ->int:
	return dict_square_weight[dict_square_type[square_type]]
	pass
#函数：预算当前节点的备选节点的G_cost的增量
func compute_increment_cost_G_by_preparing_square_xy(current_square : square, preparing_square_x : int, preparing_square_y : int, preparing_square_type : int) -> int:
	var increment_G_cost
	var preparing_square_W : int = get_square_W_by_square_type(preparing_square_type)
	if abs(current_square.x - preparing_square_x) == 1 && abs(current_square.y - preparing_square_y) == 1:
		increment_G_cost = 14 * preparing_square_W
	else:
		increment_G_cost = 10 * preparing_square_W
	return increment_G_cost
	pass
func get_square(point,x,y,type,index):
	if(fmod(point.x, 16) != 0):
		x = floor(point.x / 16)
	else:
		x = floor(point.x / 16) - 1
	if(fmod(point.y, 16) != 0):
		y = floor(point.y / 16)
	else:
		y = floor(point.y / 16) - 1
	#起始方格实例化
	type = get_square_type_by_xy(x, y)
	var mysquare = square.new(x, y, type)
	if index ==0:
		#起始点G值为0
		mysquare.set_G(0)
	return mysquare
#函数：获得AStar寻路的路径集合，用以对接外部的调用
func get_path_AStar(starting_point : Vector2, destination_point : Vector2) -> PoolVector2Array:
	# warning-ignore:unassigned_variable
	var path_AStar : PoolVector2Array
	#实例化初始和目的地方格
	#声明变量
	var starting_square : square
	var destination_square : square
	var starting_square_x
	var starting_square_y
	var starting_square_type
	var destination_square_x
	var destination_square_y
	var destination_square_type
	#坐标换算起始方格
	starting_square=get_square(starting_point,starting_square_x,starting_square_y,starting_square_type,0)
	#坐标换算目的地方格
	destination_square=get_square(destination_point,destination_square_x,destination_square_y,destination_square_type,1)
	#判断，如果初始和目的地方格都存在且合理，不是障碍和无效就进行寻路
	if(starting_square != null 
	&& destination_square != null
	&& dict_square_type[starting_square.type] != "INVALID"
	&& dict_square_type[starting_square.type] != "HINDER"
	&& dict_square_type[destination_square.type] != "INVALID"
	&& dict_square_type[destination_square.type] != "HINDER"):
		return myAstar(starting_square, destination_square)
	else:
		return path_AStar
	pass
#函数：AStar寻路主体函数
func myAstar(starting_square: square, destination_square: square) -> PoolVector2Array:
	#创建路径变量存放返回的路径点的集合
	# warning-ignore:unassigned_variable
	var path : PoolVector2Array
	#建立开放列表open，关闭列表closed
	var open_list : Array
	var closed_list : Array
	#声明一系列preparing变量用于遍历时使用 表示临近的方格neighbor_square
	var preparing_square_x : int
	var preparing_square_y : int
	var preparing_square_type : int
	var preparing_square : square
	#添加起始点到开放列表
	open_list.append(starting_square)
	#声明当前节点赋予初始值
	var current_square : square = open_list[0]
	while(open_list.empty() != true&& current_square.is_square(destination_square) != true):
	#获得F值最小的方格作为当前方格
		current_square = open_list[0]
		if current_square.is_square(destination_square):
			var path_square : square = current_square
			while(path_square.parent_square != null):
				path.insert(0, Vector2(path_square.x, path_square.y))
				path_square = path_square.parent_square
				pass
			path.insert(0, Vector2(starting_square.x, starting_square.y))
			break
		#Godot中对当前方格的周围方格下标的遍历
		#current_square的xy下标与周围方格下标的关系
		#[x-1,y-1][ x ,y-1][x+1,y-1]
		#[x-1, y ][ x , y ][x+1, y ]
		#[x-1,y+1][ x ,y+1][x+1,y+1]
		#遍历当前方格current_square周围的方格类型，判断成本
		#创建变量 预备方格
		#遍历，后期优化遍历顺序上{左上，右上}；下{左下，右下}；左；右 ps:正方向不能通过，那么斜方向静止直接通行
		for i in range(-1, 2): 
			for j in range(-1, 2):
				if !(i == 0 && j == 0):
					preparing_square_x = current_square.x + j
					preparing_square_y = current_square.y + i
					preparing_square_type = get_square_type_by_xy(preparing_square_x, preparing_square_y)
					#从上方开始判断，如果不是1表示可通行不是障碍物,-1表示外界
					if (preparing_square_x >= 0
					&& preparing_square_y >= 0
					&& dict_square_type[preparing_square_type] != "HINDER" 
					&& dict_square_type[preparing_square_type] != "INVALID"
					&& is_square_in_list(closed_list, preparing_square_x, preparing_square_y) != true):
						#计算g值
						var g : int = current_square.G + compute_increment_cost_G_by_preparing_square_xy(current_square, preparing_square_x, preparing_square_y, preparing_square_type)
						if is_square_in_list(open_list, preparing_square_x, preparing_square_y):
							var get_square : square = get_square_from_open_list_by_xy(open_list, preparing_square_x,preparing_square_y)
							if get_square.G == 0 || get_square.G > g:
								get_square.set_G(g)
								get_square.set_parent_square(current_square)
								get_square.update_F()
						else :
							preparing_square = square.new(preparing_square_x, preparing_square_y, preparing_square_type)
							preparing_square.set_G(g)
							preparing_square.set_H(preparing_square.compute_cost_H(destination_square))
							preparing_square.update_F()
							preparing_square.set_parent_square(current_square)
							open_list.append(preparing_square)
		closed_list.append(current_square)
		for i in range(open_list.size()):
			print('x',open_list[i].x,'y',open_list[i].y,'g',open_list[i].G,'F',open_list[i].F)
		open_list.remove(0)
		open_list.sort_custom(square, "sort_square_by_F")
		print("list")
		print("current",'x',current_square.x,'y',current_square.y)
		for i in range(open_list.size()):
			print('x',open_list[i].x,'y',open_list[i].y,'g',open_list[i].G,'F',open_list[i].F)
	return path
	pass
#函数：判读Array<square>中是否有给定位置的方格，主要用以open_list和closed_list的方格判断
func is_square_in_list(list: Array, x: int, y: int) ->bool:
	for i in range(list.size()):
		if list[i].x == x && list[i].y == y:
			return true
	return false

#函数：从openList中获得方格
func get_square_from_open_list_by_xy(open_list: Array, x: int, y: int) -> square:
	for i in range(open_list.size()):
		if open_list[i].x == x && open_list[i].y == y:
			return open_list[i] 
	return null
	pass 
