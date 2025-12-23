extends Node

var random = RandomNumberGenerator.new()

var mov_change_cd = 5

var mov_type_lst = [0, 1, 1]
var dir_type = [-1, 1]

var movement_type = mov_type_lst.pick_random()
var dir_x = dir_type.pick_random()
var dir_y = dir_type.pick_random()

var speed
var stress = 0
var stress_incr_factor = 0.03

signal action(speed, direction)


func _ready():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)


func _increase_stress(dir):
	var screen_size = [DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y]
	
	if get_window().position.x >= (screen_size[0] - 100):
		emit_signal("action", 0, 1)
		print("STOP R")
		dir_x = -1
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
		stress += stress_incr_factor
	
	elif get_window().position.x <= 0:
		emit_signal("action", 0, -1)
		print("STOP L")
		dir_x = 1
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
		stress += stress_incr_factor
	
	if get_window().position.y >= (screen_size[1] - 100):
		emit_signal("action", 0, dir)
		print("STOP DOWN")
		dir_y = -1
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
		stress += stress_incr_factor
	
	elif get_window().position.y <= 0:
		emit_signal("action", 0, dir)
		print("STOP UP")
		dir_y = 1
		await get_tree().create_timer(1).timeout
		mov_change_cd = 3
		stress += stress_incr_factor
		
	


func _general_movement(delta):
	speed = 1 + stress
	
	if mov_change_cd <= 0:
		movement_type = mov_type_lst.pick_random()
		dir_x = dir_type.pick_random()
		dir_y = dir_type.pick_random()
		mov_change_cd = 3
	else:
		mov_change_cd -= delta
	
	
	if movement_type == 0:
		emit_signal("action", movement_type, 0)
	
	else:
		get_window().position.x += speed * dir_x
		get_window().position.y += speed * dir_y
		emit_signal("action", movement_type, dir_x)
	


func _physics_process(_delta: float) -> void:
	_increase_stress(dir_x)
	
	if stress > 0:
		stress -= 0.01
		mov_type_lst.erase(0)
		print("stress = {}".format([stress], "{}"))
	else:
		if 0 not in mov_type_lst:
			mov_type_lst.append(0)
			
	_general_movement(_delta)
			
