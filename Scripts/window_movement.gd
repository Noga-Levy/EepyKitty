"""
Written in December 2025 to March of 2026 by Noga Levy.

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
var stress_incr: float = 0.9  # The smallest factor for which base stress can increase to
var stress_decr: float = 0.01 # The smallest factor for which base stress can decrease

# As for energy, the delta determiner below will be utilized to regulate change in energy.
var energy_dlt = 0.05

# A random int will be selected from 0 to range_idle to deteremine if the cat will go idle. The 
# larger range_idle is, the less likely
var range_idle = 1  # More stress = higher number

# As the name suggests, this variable decides which action to take when the previous on reaches the
# end.
var activity_decider

func _ready() -> void:
	# We first ensure that the cat does not get covered by other windows
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	# Next, we detect window callbacks, such as the mouse entering the window, thus touching the cat
	DisplayServer.window_set_window_event_callback(_window_callback)
	# And make sure that new windows are not embedded into the main one.
	get_viewport().set_embedding_subwindows(false)
	$Food.show()
	
	# Finally, we set the starting values for stress and energy.
	Global.stress = 0
	Global.energy = 1


# Function for window callbacks
func _window_callback(event: int):
	
	# We first check to see if the user wishes to close the program
	if event == DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
		get_tree().quit()
	
	# Then we check if the mouse entered the window
	if event == DisplayServer.WINDOW_EVENT_MOUSE_ENTER:
		# We set these to false so that the user cannot force the cat to go off-screen
		responded_bx = false
		responded_sx = false
		responded_by = false
		responded_sy = false
		
		# Now, we begin the reaction to the mouse interaction
		if Global.x != 0:
			Global.action.emit(0, Global.x)  # Surprised cat animation
			# Set the change in x and y while we wait for the "right" itself.
			window_mvment = false
			Global.x *= -1
			Global.y *= -1
			await get_tree().create_timer(1).timeout
			# Finally, we add the stress and continue the movement
			window_mvment = true
			Global.stress += stress_incr * 2
			Global.action.emit(1 + Global.stress, Global.x)
		else:
			pass

# Function to figure out if the cat has reached the end, and what to do if it has
func _is_touching_edge():
	
	# Right edge
	if get_window().position.x > screen_size[0] - 110:
		if not responded_bx:
			Global.x = -1
			Global.action.emit(0, 1)
			window_mvment = false
			responded_bx = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, -1)
	else:
		responded_bx = false
	
	# Left edge
	if get_window().position.x < 10:
		if not responded_sx:
			Global.x = 1
			Global.action.emit(0, -1)
			window_mvment = false
			responded_sx = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, 1)
	else:
		responded_sx = false
	
	# Top edge
	if get_window().position.y > screen_size[1] - 110:
		if not responded_by:
			Global.y = -1
			Global.action.emit(0, Global.x)
			window_mvment = false
			responded_by = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, Global.x)
	else:
		responded_by = false
	
	# Bottom edge
	if get_window().position.y <  10:
		if not responded_sy:
			Global.y = 1
			Global.action.emit(0, Global.x)
			window_mvment = false
			responded_sy = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			Global.stress += stress_incr
			Global.action.emit(Global.speed, Global.x)
	else:
		responded_sy = false

func _process(delta: float) -> void:
	_is_touching_edge()
	# Involving both stress and energy--though the latter, less so--we calculate
	# the speed using powers, since we want to go faster when we have more
	# stress/energy, and slower when we have less.
	Global.speed = 0.5 + pow(1.05, 2 * Global.stress) + pow(1.01, Global.energy)/5
	print(Global.speed)
	
	#  If actions can/should be taken...
	if window_mvment:
		# Check for unintended behavior
		if Global.x * 2 * Global.speed == 0 and Global.y * 2 * Global.speed != 0:
			# Response for said behavior
			push_error("The change in x = 0, and the change in y is not.")
			
		# Update window position
		get_window().position.x += Global.x * 2 * Global.speed # Later, we can take this coords and
		# plot them
		get_window().position.y += Global.y * 2 * Global.speed
		Global.energy += energy_dlt - (energy_dlt * Global.stress)
		Global.energy = clampf(Global.energy, Global.ENERGY_MIN, Global.ENERGY_MAX)
		
		# Deals with energy when it reaches 0
		if Global.energy <= 0:
			stress_decr = 0.02
			Activities.switch_action_cd = 10
			activity_decider = "REST"
		
		if not Global.goal_in_progress:
			activity_decider = ["WANDER", "REST"].pick_random()
			print(activity_decider)
			Global.goal_in_progress = true
		else:
			if activity_decider == "WANDER":
				Activities.WANDER(delta, range_idle, stress_decr, energy_dlt)
			else:
				Activities.REST(delta, energy_dlt)
			
		
		# Decreases stress if it is above 0, and increases range_idle (for the same prerequisites)
		if Global.stress > 0:
			Global.stress -= stress_decr * (Global.stress + 1) # Decays faster at high stress, 
			# slower at low stress.
			range_idle = 1 + clampi(roundi(10 * Global.stress - Global.energy), 0, 100)
