extends Node

var switch_action_cd = 10
var switch_dir_cd = 3

# NOTE: These functions/actions will be called every time proccess is run. This is intentional, as
# we must be able to subtract delta from process() of the main file.

func WANDER(delta, range_idle, stress_decr, energy_dlt):
	# Countdown until the cat randomly changes direction
	if switch_action_cd > 0:
		switch_action_cd -= delta
		
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
	if switch_action_cd > 0:
		switch_action_cd -= delta
		Global.x = 0
		Global.y = 0
		Global.action.emit(-1, 0)
		Global.energy += energy_dlt * 2 * energy_dlt
	else:
		switch_action_cd = 10
		Global.goal_in_progress = false
		# FIXME: The two lines below cause the cat to move a bit before the next action is decided;
		# however, it also ensures that, if the next action is WANDER, it will have a direction.
