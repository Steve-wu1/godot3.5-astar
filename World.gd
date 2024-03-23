extends Node2D



# 声明变量start_point 起始点
# 声明变量destination_point 目的地点
var starting_point : Vector2
var destination_point : Vector2
var path_AStar : PoolVector2Array 
onready var grid_navigation_AStar = $TileMap
onready var line_2d = $Line2D
onready var starting = $starting
onready var destination = $destination

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("mouse_left"):
		starting_point = event.position
		starting.position = starting_point
		pass
	if event.is_action_released("mouse_right"):
		destination_point = event.position
		destination.position = destination_point
		pass
	if event.is_action_released("enter"):
		path_AStar = grid_navigation_AStar.get_path_AStar(starting_point, destination_point)
		if(path_AStar != null):
			print(path_AStar)
			# warning-ignore:unassigned_variable
			var path_in_world : PoolVector2Array 
			# warning-ignore:unassigned_variable
			var vector2 : Vector2
			for i in range(path_AStar.size()):
				vector2.x = path_AStar[i].x * 16 + 8
				vector2.y = path_AStar[i].y * 16 + 8
				path_in_world.append(vector2)
				line_2d.points = path_in_world
		else:
			print("path_AStar is NULL")
			pass
		pass 
