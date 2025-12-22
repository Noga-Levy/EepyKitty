extends Node2D

var random = RandomNumberGenerator.new()

var mov_change_cd = 5 #10

var mov_type_lst = [0, 1, 2]
var dir_type_x = ["L", "R"]
var dir_type_y = [-1, 1]

var movement_type = mov_type_lst.pick_random()
var dir_x = dir_type_x.pick_random()
var dir_y = dir_type_y.pick_random()

var speed

signal action(speed, direction)

func _ready():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)


func _is_at_edge(delta, dir):
	var screen_size = [DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y]
	
	if get_window().position.x >= (screen_size[0] - 100):
		emit_signal("action", 0, "R")
		print("STOP R")
		dir_x = "L"
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
	
	elif get_window().position.x <= 0:
		emit_signal("action", 0, "L")
		print("STOP L")
		dir_x = "R"
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
	
	if get_window().position.y >= (screen_size[1] - 100):
		emit_signal("action", 0, dir)
		print("STOP DOWN")
		dir_y = -1
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
	
	elif get_window().position.y <= 0:
		emit_signal("action", 0, dir)
		print("STOP UP")
		dir_y = 1
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
		
	_general_movement(delta)


func _general_movement(delta):
	if mov_change_cd <= 0:
		movement_type = mov_type_lst.pick_random()
		dir_x = dir_type_x.pick_random()
		dir_y = dir_type_y.pick_random()
		mov_change_cd = 3
	else:
		mov_change_cd -= delta
	
	
	if movement_type == 0:
		# $Cat.animation = movement_type
		emit_signal("action", movement_type, "")
		get_window().position.x += 0
	
	else:
		# $Cat.animation = movement_type + dir_x
		if dir_x == "L":
			speed = movement_type
			get_window().position.x -= speed
			
		else:
			speed = movement_type
			get_window().position.x += speed
		
		get_window().position.y += speed * dir_y
		emit_signal("action", movement_type, dir_x)


func _physics_process(delta: float) -> void:
	_is_at_edge(delta, dir_x)
	
