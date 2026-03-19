"""
Written in March 2026 by Noga Levy.

activities.gd is the collection of all actions the cat can take. By plugging one of the functions
into the right area of process() in window_movement.gd, one gets the cat to perform the action.
"""

extends Node

var switch_action_cd = 10
var switch_dir_cd = 3

# NOTE: These functions/actions will be called every time proccess is run. This is intentional, as
# we must be able to subtract delta from process() of the main file.


func WANDER(delta, range_idle, stress_decr, energy_dlt):
	# Countdown until the cat randomly changes direction
	if switch_action_cd > 0:
		switch_action_cd -= delta
		
		# If the previous action was REST or something similar, we need to pick a direction to go in
		if Global.x == 0 or Global.y == 0:
			Global.x = Global.dir_opts.pick_random()
			Global.y = Global.dir_opts.pick_random()
		
		if switch_dir_cd > 0:
			switch_dir_cd -= delta
			Global.action.emit(Global.speed, Global.x)
		elif randi_range(0, range_idle) != 0:
			Global.x = Global.dir_opts.pick_random()
			Global.y =  Global.dir_opts.pick_random()
			Global.action.emit(Global.speed, Global.x)
			switch_dir_cd = 3
			stress_decr = 0.01
			energy_dlt = -0.01
		else:
			Global.x = 0
			Global.y = 0
			Global.action.emit(0, 0)
			switch_dir_cd = 3
			stress_decr = 0.02
			energy_dlt = 0.01
	
	else:
		Global.goal_in_progress = false
		switch_action_cd = 10


func REST(delta, energy_dlt):
	# If REST called for the first time, we must set a couple variables and call an action
	if switch_action_cd == 10:
		# These three commands below only need to be emitted once at the beginning
		Global.x = 0
		Global.y = 0
		Global.action.emit(-1, 0)
	
	# Since 10 > 0, we don't need to worry about the above if statement not subtracting delta or
	# increasing Global.energy
	if switch_action_cd > 0:
		switch_action_cd -= delta
		Global.energy += energy_dlt * 2 * energy_dlt
	else:
		switch_action_cd = 10
		Global.goal_in_progress = false


func EAT(delta, stress_decr, energy_dlt):
	if switch_action_cd == 10:
		switch_action_cd = 5
	
	var cat_posx = get_window().position.x
	var cat_posy = get_window().position.y
	
	if switch_action_cd > 0:
		if abs(Global.food_posx - cat_posx) < 15 and abs(Global.food_posy - cat_posy) < 15:
			Global.x = 0
			Global.y = 0
			Global.action.emit(-1, 0)
			switch_action_cd -= delta
		
		else:
			if (Global.food_posx - cat_posx) < 0:
				Global.x = -1
			else:
				Global.x = 1
			
			if (Global.food_posy - cat_posy) < 0:
				Global.y = -1
			else:
				Global.y = 1
			
			stress_decr = 0.01
			energy_dlt = -0.01
			
			Global.action.emit(Global.speed, Global.x)
	else:
		switch_action_cd = 10
		Global.goal_in_progress = false
