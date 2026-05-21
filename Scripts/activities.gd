"""
Written in March 2026 by Noga Levy.

activities.gd is the collection of all actions the cat can take. By plugging one of the functions
into the right area of process() in window_movement.gd, one gets the cat to perform the action.
"""

extends Node

var switch_action_cd = 10
var switch_dir_cd = 3
var max_comfort_value
var max_comfort_square
var comfort_dlt = 0


# NOTE: The function below is not an activity--it is merely the function for finding the current
# comfort grid, for which we often need.
func grid_coordinate():
	var current_coords = DisplayServer.window_get_position(Global.cat_window_id)
	var current_grid_x = floor(current_coords.x/50) * 50
	var current_grid_y = floor(current_coords.y/50) * 50
	
	return [current_grid_x, current_grid_y]


# NOTE: Additionally, this function relates to the WANDER() function, to find the requires direction
# of x and y. It is not an activity in of itself.
func find_path(x_current, y_current, x_desired, y_desired):
	var x_dir = 0
	var y_dir = 0
	
	if (x_desired - x_current) > 0:
		x_dir = 1
	elif (x_desired - x_current) < 0:
		x_dir = -1
	
	if (y_desired - y_current) > 0:
		y_dir = 1
	elif (y_desired - y_current) < 0:
		y_dir = -1
	
	return [x_dir, y_dir]


# NOTE: Likewise, function below also is not an activity--it is the function for deciding the next 
# activity
func activity_decider():
	print("{stress}, {energy}, {speed}".format({"stress": Global.stress, "energy": Global.energy,
	"speed": Global.speed}))
	# Used for deciding the next activity via a set of equations for each one--whichever yields the
	# highest value becomes the next "goal."
	
	# Setup variables
	var e = exp(1.0)
	var score = {"WANDER": 0, "REST": 0, "EAT": 0}
	
	# Equations:
	score["WANDER"] = (Global.energy * 0.5) - (Global.stress * 2)  # Wandering score
	score["REST"] = (Global.stress * 3) - Global.energy/2  		   # Resting score
	score["EAT"] = 2 * e ** (-((Global.energy - 2.5)**2)/0.5)  	   # Eating score
	
	print(score)
	
	var current_goal
	current_goal = score.values().max()
	current_goal = score.find_key(current_goal)
	
	return current_goal


# NOTE: Now we have tha actual actions. They will be called every time proccess is run. This is 
# intentional, as we must be able to subtract delta from process() of the main file.


func WANDER(delta, range_idle, stress_decr, energy_dlt):
	# If WANDER just started and the previous action was REST or something similar, we need to pick
	# a direction to go in. Moreover, we also need to set switch_dir_cd to 0 so we can choose our 
	# next action.
	if switch_action_cd == 10 and (Global.x == 0 or Global.y == 0):
		Global.x = Global.dir_opts.pick_random()
		Global.y = Global.dir_opts.pick_random()
		switch_dir_cd = 0
	
	# Countdown until the cat changes action
	if switch_action_cd > 0:
		switch_action_cd -= delta
		# We update the comfort of the current square as the program progresses.
		Global.comfort_grid[grid_coordinate()] += comfort_dlt
		print(Global.comfort_grid[grid_coordinate()])
		
		# Countdown until the cat changes direction and/or idling status
		if switch_dir_cd > 0:
			switch_dir_cd -= delta
			Global.action.emit(Global.speed, Global.x)
			
		elif randi_range(0, range_idle) != 0:
			print("Not 0. {range}".format({"range": range_idle}))
			# If the cat isn't all that stressed, then it can wander aimlessly
			if Global.stress <= 0.5:
				print(Global.stress)
				Global.x = Global.dir_opts.pick_random()
				Global.y =  Global.dir_opts.pick_random()
				# As it wanders, it should become more comfortable with the current square.
				comfort_dlt = 0.03
				
			else:
				# We create a modified comfort grid, where we do not count our current square as the
				# maximum value, to avoid getting stuck there. 
				var modified_grid = Global.comfort_grid
				var current_square = grid_coordinate()
				modified_grid[current_square] -= modified_grid[current_square]
				
				# Now, we find the square with the largest value.
				max_comfort_value = modified_grid.values().max()
				max_comfort_square = modified_grid.find_key(max_comfort_value)
				print(max_comfort_square)
				
				var xy_dir_list = find_path(current_square[0], current_square[1],
				 max_comfort_square[0], max_comfort_square[1])
				
				Global.x = xy_dir_list[0]
				Global.y =  xy_dir_list[1]
				# Since the cat is stressed, the comfort value of the squares it passes by should
				# decrease.
				comfort_dlt = -0.02
			
			Global.action.emit(Global.speed, Global.x)
			switch_dir_cd = 3
			stress_decr = 0.001
			energy_dlt = -0.01
			
		else:
			print("Is 0. {range}".format({"range": range_idle}))
			Global.x = 0
			Global.y = 0
			Global.action.emit(0, 0)
			switch_dir_cd = 3
			stress_decr = 0.002
			energy_dlt = 0.01
			# Since the cat is idling, the comfort of the square can increase.
			comfort_dlt = 0.03
			
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
		# We calculate the grid coordinates and increase the comfort of the square
		var grid_square = grid_coordinate()
		Global.comfort_grid[grid_square] += 0.01
		# And now we deal with the variables
		switch_action_cd -= delta
		Global.energy += energy_dlt * 2 * energy_dlt
	else:
		switch_action_cd = 10
		Global.goal_in_progress = false


func EAT(delta, stress_decr, energy_dlt):
	# We only want the cat to eat for 5 seconds, so we update switch_action_cd accordingly.
	if switch_action_cd == 10:
		switch_action_cd = 5
	
	# These two variables will be used in our movement calculations
	var cat_posx = get_window().position.x
	var cat_posy = get_window().position.y
	
	if switch_action_cd > 0:
		# When within a certain range of the foodbowl, stop moving, play the eat animation, and 
		# decrease the countdown
		if abs(Global.food_posx - cat_posx) < 15 and abs(Global.food_posy - cat_posy) < 15:
			Global.x = 0
			Global.y = 0
			Global.action.emit(-2, 0)
			switch_action_cd -= delta
			# As the cat is eating, though, we must also calculate the grid coordinates and increase
			# the comfort of the square
			var grid_square = grid_coordinate()
			Global.comfort_grid[grid_square] += 0.01
		
		# If it's not, find where the food bowl is, and go to it.
		else:
			if (Global.food_posx - cat_posx) < 0:
				Global.x = -1
			else:
				Global.x = 1
			
			if (Global.food_posy - cat_posy) < 0:
				Global.y = -1
			else:
				Global.y = 1
			
			stress_decr = 0.001
			energy_dlt = -0.01
			
			Global.action.emit(Global.speed, Global.x)
	else:
		switch_action_cd = 10
		Global.goal_in_progress = false
