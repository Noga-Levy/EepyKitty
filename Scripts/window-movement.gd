extends Node2D

var random = RandomNumberGenerator.new()

var mov_change_cd = 5 #10

var mov_type_lst = ["idle", "run", "rush"]
var dir_type_lst = ["L", "R"]

var movement_type = mov_type_lst.pick_random()
var direction = dir_type_lst.pick_random()

func _physics_process(delta: float) -> void:
	if mov_change_cd <= 0:
		movement_type = mov_type_lst.pick_random()
		direction = dir_type_lst.pick_random()
		mov_change_cd = 5
	else:
		mov_change_cd -= delta
	
	if movement_type == "idle":
		$Cat.animation = movement_type
		get_window().position.x += 0
	else:
		$Cat.animation = movement_type + direction
		if direction == "L":
			get_window().position.x -= 1
		else:
			get_window().position.x += 1
