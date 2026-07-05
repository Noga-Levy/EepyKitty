"""
Written in March to June 2026 by Noga Levy.

activities.gd is the collection of all actions the cat can take. By plugging one of the functions
into the right area of process() in window_movement.gd, one gets the cat to perform the action.
"""

extends Node

var switch_action_cd = 10
var switch_dir_cd = 3

var max_comfort_value   # Highest value from the comfort map.
var max_comfort_square  # Gris square of the highest value from the comfort map.
var comfort_dlt = 0     # The change in comfort for each square at a particular time.

# Directions for x and y.
const RIGHT = 1
const LEFT = -1
const DOWN = 1
const UP = -1

# NOTE: The function below is not an activity--it is merely the function for finding the current
# comfort grid, for which we often need.
func grid_coordinate():
	var current_coords = DisplayServer.window_get_position(Global.cat_window_id)
	var current_grid_x = floor(current_coords.x/Global.GRID_SQUARE_SIZE) * Global.GRID_SQUARE_SIZE
	var current_grid_y = floor(current_coords.y/Global.GRID_SQUARE_SIZE) * Global.GRID_SQUARE_SIZE
	
	return [current_grid_x, current_grid_y]


# NOTE: Additionally, this function relates to the WANDER() function, to find the requires direction
# of x and y. It is not an activity in of itself.
func find_path(x_current, y_current, x_desired, y_desired):
	var x_dir = 0
	var y_dir = 0
	
	if (x_desired - x_current) > 0:
		x_dir = RIGHT
	elif (x_desired - x_current) < 0:
		x_dir = LEFT
	
	if (y_desired - y_current) > 0:
		y_dir = DOWN
	elif (y_desired - y_current) < 0:
		y_dir = UP
	
	return [x_dir, y_dir]


# NOTE: Likewise, function below also is not an activity--it is the function for deciding the next 
# activity
func activity_decider():
	print("Stess: {stress}, Energy: {energy}, Speed: {speed}".format(
		{"stress": Global.stress,
		 "energy": Global.energy,
		 "speed": Global.speed}))
	# Used for deciding the next activity via a set of equations for each one--whichever yields the
	# highest value becomes the next "goal."
	
	# Score keeper
	var score = {"WANDER": 0, "REST": 0, "EAT": 0}
	
	# Equations:
	# Wandering score equation
	const WANDER_STRESS_WEIGHT = 2
	const WANDER_ENERGY_WEIGHT = 0.5
	score["WANDER"] = ((WANDER_ENERGY_WEIGHT * Global.energy) -
					   (WANDER_STRESS_WEIGHT * Global.stress))
	
	# Resting score equation
	const REST_STRESS_WEIGHT = 3
	const REST_ENERGY_WEIGHT = 0.5
	score["REST"] = (REST_STRESS_WEIGHT * Global.stress) - (REST_ENERGY_WEIGHT * Global.energy)
	
	# Eating score equation
	const MOST_DESIRABLE_ENERGY = 2.5
	const MAX_CURVE_HEIGHT = 2
	const CURVE_DROPOFF = 0.5
	# Gaussian function, creates a bell-curve
	score["EAT"] = MAX_CURVE_HEIGHT * Global.EULERS_NUMBER ** (
									-((Global.energy - MOST_DESIRABLE_ENERGY) ** 2)/CURVE_DROPOFF)
	
	var current_goal
	current_goal = score.values().max()
	current_goal = score.find_key(current_goal)
	
	print("\nCurrent goal: {goal}".format([current_goal], "{goal}"))
	print("\nGoal scores: {dictionary}".format([score], "{dictionary}"))
	
	return current_goal


# NOTE: Now we have the actual actions. They will be called every time proccess is run. This is 
# intentional, as we must be able to subtract delta--obtained from the process() function of the
# main file.


func WANDER(delta, range_idle):
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
		
		# Countdown until the cat changes direction and/or idling status
		if switch_dir_cd > 0:
			switch_dir_cd -= delta
			Global.action.emit(Global.speed, Global.x)
			
		elif randi_range(0, range_idle) != 0:
			print("\nNot idling. range_idle = {range}".format({"range": range_idle}))
			# If the cat isn't all that stressed, then it can wander aimlessly
			if Global.stress <= 0.5:
				print("\nStress: {stress}".format([Global.stress], "{stress}"))
				Global.x = Global.dir_opts.pick_random()
				Global.y =  Global.dir_opts.pick_random()
				# As it wanders, it should become more comfortable with the current square.
				comfort_dlt = 0.03
				
			else:
				# We create a modified comfort grid, where we do not count our current square as the
				# maximum value, to avoid getting stuck there. 
				var modified_grid = Global.comfort_grid.duplicate()  # We must add the .duplicate()
																	 # so that our changes to the
																	 # modified_grid don't affect
																	 # the values in original dict.
				var current_square = grid_coordinate()
				modified_grid[current_square] -= modified_grid[current_square]
				
				# Now, we find the square with the largest value.
				max_comfort_value = modified_grid.values().max()
				max_comfort_square = modified_grid.find_key(max_comfort_value)
				print("\nMax comfort square: [{0}, {1}]".format([max_comfort_square[0],
																 max_comfort_square[1]]))
				
				var xy_dir_list = find_path(current_square[0], current_square[1],
				max_comfort_square[0], max_comfort_square[1])
				
				Global.x = xy_dir_list[0]
				Global.y =  xy_dir_list[1]
				# Since the cat is stressed, the comfort value of the squares it passes by should
				# decrease.
				comfort_dlt = -0.02
			
			Global.action.emit(Global.speed, Global.x)
			switch_dir_cd = 3
			Global.stress_decr = 0.001
			Global.energy_dlt = -0.01
			
		else:
			print("\nIdling. range_idle = {range}".format({"range": range_idle}))
			Global.x = 0
			Global.y = 0
			Global.action.emit(0, 0)
			switch_dir_cd = 3
			Global.stress_decr = 0.002
			Global.energy_dlt = 0.01
			# Since the cat is idling, the comfort of the square can increase.
			comfort_dlt = 0.03
			
	else:
		Global.goal_in_progress = false
		switch_action_cd = 10


func REST(delta):
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
		"""
		We take the absolute value of energy_dlt because we always want to increase energy after
		sleeping. Otherwise, if we are at 0 energy, we'll automatically rest with a negative dlt,
		leading to a glitch where, since the energy must be in the range of [0, 3], we forever
		have energy at 0 (0 --> rests --> goes negative due to the sign of the dlt --> rounds to 0).
		"""
		const DLT_WEIGHT = 2
		Global.energy += DLT_WEIGHT * abs(Global.energy_dlt)
		# NOTE: We could square the dlt to make it positive, but that creates a miniscule value just 
		# waiting to cause floating point errors.
		
	else:
		switch_action_cd = 10
		Global.goal_in_progress = false


func EAT(delta):
	# We only want the cat to eat for 5 seconds, so we update switch_action_cd accordingly.
	if switch_action_cd == 10:
		switch_action_cd = 5
	
	# These two variables will be used in our movement calculations
	var cat_posx = get_window().position.x
	var cat_posy = get_window().position.y
	
	if switch_action_cd > 0:
		# When within a certain range of the food bowl, stop moving, play the eat animation, and 
		# decrease the countdown
		const FB_RANGE = 15  # Maximum distance the cat can be from the food bowl (fb)
		if (abs(Global.food_posx - cat_posx) < FB_RANGE 
			and abs(Global.food_posy - cat_posy) < FB_RANGE):
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
			var xy_dirs: Array = find_path(cat_posx, cat_posy, Global.food_posx, Global.food_posy)
			Global.x = xy_dirs[0]
			Global.y = xy_dirs[1]
			
			Global.stress_decr = 0.001
			Global.energy_dlt = -0.01
			
			Global.action.emit(Global.speed, Global.x)
	else:
		switch_action_cd = 10
		Global.goal_in_progress = false
