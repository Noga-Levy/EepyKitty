"""
Written in December of 2025 to June of 2026 by Noga Levy.

This program acts as the brains to the emergent behavior system, handling the window movement and
calculations.
"""

extends Node2D

var screen_size = DisplayServer.screen_get_size()

# These 4 variables are to keep the computer from spamming "[x/y] is too [big/small]!" when the
# animation is playing
var responded_bx = false
var responded_sx = false
var responded_by = false
var responded_sy = false

# We will use the variable below to start and stop window movement
var window_mvment = true

# After bumping into a wall or mouse, the stress increases, and increase's the cat's speed.
var stress_incr: float = 0.9  # The factor for which base stress can increase to
# stress_decr is a variable in Global, as it is used in a number of other scripts. stress_incr, on 
# the other hand, is only used in this script, so we define it locally.

# A random int will be selected from 0 to range_idle to deteremine if the cat will go idle. The 
# larger range_idle is, the less likely
var range_idle = 1  # More stress = higher number

# As the name suggests, this variable decides which action to take when the previous on reaches the
# end.
var next_activity


func _ready() -> void:
	# We first ensure that the cat does not get covered by other windows
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	# Next, we detect window callbacks, such as the mouse entering the window, thus touching the cat
	DisplayServer.window_set_window_event_callback(_window_callback)
	# And make sure that new windows are not embedded into the main one.
	get_viewport().set_embedding_subwindows(false)
	$Food.show()
	
	Global.cat_window_id = get_window().get_window_id()
	
	# Finally, we set the starting values for stress and energy.
	Global.stress = 0
	Global.energy = 1


# Function for window callbacks
func _window_callback(event: int):
	
	# We first check to see if the user wishes to close the program
	if event == DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
		get_tree().quit()
	
	# Then we check if the mouse entered the window (if it has, the cat becomes spooked)
	if event == DisplayServer.WINDOW_EVENT_MOUSE_ENTER:
		# We set these to false so that the user cannot force the cat to go off-screen
		responded_bx = false
		responded_sx = false
		responded_by = false
		responded_sy = false
		
		# And we set these constants for the the reaction.
		const SPOOKED_MOUSE_TIMEOUT = 3
		const STRESS_INCR_WEIGHT = 2
		
		# Now, we begin the reaction to the mouse interaction
		if Global.x != 0:
			Global.action.emit(0, Global.x)  # Surprised cat animation
			# Set the change in x and y while we wait for the "right" itself.
			window_mvment = false
			Global.x *= -1
			Global.y *= -1
			await get_tree().create_timer(SPOOKED_MOUSE_TIMEOUT).timeout
			# Finally, we add the stress and continue the movement
			window_mvment = true
			Global.stress += stress_incr * STRESS_INCR_WEIGHT
			Global.action.emit(1 + Global.stress, Global.x)
		else:
			pass


# Used in the reaction for _is_touching_edge().
func _calc_comoft_decline():
	# Constants for calculating the comfort decline.
	const TOTAL_WIDTH = 8  # Used for CURVE_DROPOFF, in the equation calculating how wide the curve
						   # should be
	const CURVE_DROPOFF = 2 * ((TOTAL_WIDTH/6.0)**2)  # Equation inspired by 2σ²
	const DESIRABLE_DECLINE = 0.02
	const MAX_DECLINE_HEIGHT = 0.025
	var comfort_decline = MAX_DECLINE_HEIGHT * Global.EULERS_NUMBER ** (
						 -(((Global.stress + Global.energy) - DESIRABLE_DECLINE)
						 ** 2)/CURVE_DROPOFF)
	
	print("Comfort_decline = {comfort_decline}".format({"comfort_decline": comfort_decline}))
	return comfort_decline

# Function to figure out if the cat has reached the end, and what to do if it has
func _is_touching_edge():
	# We set the timeout and comfort decline
	const SPOOKED_EDGE_TIMEOUT = 1  # How long the cat should stop and play the spooked animation.
	
	# Right edge
	if get_window().position.x > screen_size[0] - 110:
		if not responded_bx:
			Global.x = -1
			Global.action.emit(0, 1)
			window_mvment = false
			responded_bx = true
			await get_tree().create_timer(SPOOKED_EDGE_TIMEOUT).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, -1)
			Global.comfort_grid[Activities.grid_coordinate()] -= _calc_comoft_decline()
	else:
		responded_bx = false
	
	# Left edge
	if get_window().position.x < 10:
		if not responded_sx:
			Global.x = 1
			Global.action.emit(0, -1)
			window_mvment = false
			responded_sx = true
			await get_tree().create_timer(SPOOKED_EDGE_TIMEOUT).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, 1)
			Global.comfort_grid[Activities.grid_coordinate()] -= _calc_comoft_decline()
	else:
		responded_sx = false
	
	# Top edge
	if get_window().position.y > screen_size[1] - 110:
		if not responded_by:
			Global.y = -1
			Global.action.emit(0, Global.x)
			window_mvment = false
			responded_by = true
			await get_tree().create_timer(SPOOKED_EDGE_TIMEOUT).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, Global.x)
			Global.comfort_grid[Activities.grid_coordinate()] -= _calc_comoft_decline()
	else:
		responded_by = false
	
	# Bottom edge
	if get_window().position.y <  10:
		if not responded_sy:
			Global.y = 1
			Global.action.emit(0, Global.x)
			window_mvment = false
			responded_sy = true
			await get_tree().create_timer(SPOOKED_EDGE_TIMEOUT).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, Global.x)
			Global.comfort_grid[Activities.grid_coordinate()] -= _calc_comoft_decline()
	else:
		responded_sy = false


# Function (that will be called every time _process runs) to move all of the comfort values to 0,
# 0.001 points at a time.
func _decay_comfort():
	# For rounding, we set the constant ROUND_DP to use throughout the program
	const ROUND_DP = 0.001
	# And, to control the decay, we have the constant COMFORT_DECAY set to 0.001
	const COMFORT_DECAY = 0.001
	for i in Global.comfort_grid:
		if Global.comfort_grid[i] > 0:
			Global.comfort_grid[i] -= COMFORT_DECAY
		elif Global.comfort_grid[i] < 0:
			Global.comfort_grid[i] += COMFORT_DECAY
		
		# We round the value to the nearest 0.001 (ROUND_DP) avoid floating-point precision errors
		Global.comfort_grid[i] = snappedf(Global.comfort_grid[i], ROUND_DP)


func _process(delta: float) -> void:
	get_window().move_to_foreground()
	_is_touching_edge()
	_decay_comfort()
	# Involving both stress and energy--though the latter, less so--we calculate
	# the speed using powers, since we want to go faster when we have more
	# stress/energy, and slower when we have less.
	const SPEED_BASIS = 0.5   # Base value for speed, for which we add to.
	const STRESS_BASE = 1.06  # Base of [Global.stress] * [STRESS_WEIGHT]
	const INTERNAL_WEIGHT = 2 # Weight of internal variables as the exponents.
	const ENERGY_BASE = 1.01  # Base of [Global.energy] * [ENERGY_WEIGHT]
	const ENERGY_DIVISOR = 5  # Number for which we divide the effect of Global.energy 
	Global.speed = SPEED_BASIS + (pow(STRESS_BASE, INTERNAL_WEIGHT * Global.stress) + 
								  pow(ENERGY_BASE, INTERNAL_WEIGHT * Global.energy)/ENERGY_DIVISOR)
	
	#  If actions can/should be taken...
	if window_mvment:
		# Update window position
		get_window().position.x += Global.x * 2 * Global.speed # Later, we can take this coords and
															   # plot them
		get_window().position.y += Global.y * 2 * Global.speed
		Global.energy += Global.energy_dlt - (abs(Global.energy_dlt) * Global.stress)
		Global.energy = clampf(Global.energy, Global.ENERGY_MIN, Global.ENERGY_MAX)
		
		# Deals with energy when it reaches 0
		if Global.energy <= 0:
			Global.stress_decr = 0.002
			Activities.switch_action_cd = 10
			next_activity = "REST"
		
		if not Global.goal_in_progress:
			next_activity = Activities.activity_decider()
			Global.goal_in_progress = true
		else:
			if next_activity == "WANDER":
				Activities.WANDER(delta, range_idle)
			elif next_activity == "REST":
				Activities.REST(delta)
			else:
				Activities.EAT(delta)
			
		
		# Decreases stress if it is above 0, and increases range_idle (for the same prerequisites)
		if Global.stress > 0:
			Global.stress -= Global.stress_decr * (Global.stress + 1) # Decays faster at high 
																	  # stress, slower at low 
																	  # stress.
																	
			# 1 is the minimum value of range_idle, and we set the range for which it can equal to
			# the interval [1, 101] (as we take [0,100] and add 1 to the value from clampi).
			range_idle = 1 + clampi(roundi(10 * Global.stress - Global.energy), 0, 100)


# Function that listens for inputs, particularly Shift + Space, which the function will use to
# control the visibility of the comfort map.
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("shift_plus_space"):
		if $Comfort_map.visible:
			$Comfort_map.hide()
		else:
			$Comfort_map.show()
