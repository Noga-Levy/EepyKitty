extends Node

var switch_dir_cd = 5


func WANDER(delta, range_idle, stress_decr, energy_dlt):
	# Countdown until the cat randomly changes direction
		if switch_dir_cd > 0:
			switch_dir_cd -= delta
		elif randi_range(0, range_idle) != 0:
			var dir_opts = [-1, 1]
			Global.x = dir_opts.pick_random()
			Global.y =  dir_opts.pick_random()
			Global.action.emit(1, Global.x)
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
			
