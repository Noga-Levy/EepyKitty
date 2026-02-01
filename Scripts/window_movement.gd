"""
Written in December 2025 to February of 2026 by Noga Levy.

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

signal action(speed, direction)  # Signal to communicate with the cat animation

# And, finally, we'll multiply x and y by the speed of the cat in process to simulate
# the direction it'll go in.
var x = 1
var y = 1

# After bumping into a wall or mouse, the stress increases, and increase's the cat's speed.
var stress = 0
var stress_incr: float = 0.9  # The smallest factor for which base stress can increase to
var stress_decr: float = 0.01 # The smallest factor for which base stress can decrease

# These will be the main variables for the energy system. When the cat runs around, energy 
# decreases, with the amount proportional to the stress level. Additionally, when idling, the energy
# increases. If energy reaches 0, the cat stops whatever it's doing and idles, with an increased
# energy_dlt amount.
const ENERGY_MIN: float = 0  # ENERGY MINIMUM, so it cannot go into the negative, breaking some of
							 # the calculations and functionality.
const ENERGY_MAX: float = 2  # ENERGY MAXIMUM, so it cannot get infinitely higher, encountering the
							 # same issue as with stress (when it did not have a limiter).
var energy: float = 1        # ENERGY itself, the variable that gets acted upon and acts upon others
var energy_dlt = 0           # ENERGY DELTA, the change in energy.

# A random int will be selected from 0 to range_idle to deteremine if the cat will go idle. The 
# larger range_idle is, the less likely
var range_idle = 1  # More stress = higher number

# This will act as the timer until the cat randomly switches direction
var switch_dir_cd = 0  # Starts at 0, usually will be at 3

# Finally, we have the speed of the cat, which will be defined later in the code.
var speed

func _ready() -> void:
	# We first ensure that the cat does not get covered by other windows
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	# And then detect window callbacks, such as the mouse entering the window, thus touching the cat
	DisplayServer.window_set_window_event_callback(_window_callback)
	# Finally, we set our first animation
	emit_signal("action", 1, x)


# Function for window callbacks
func _window_callback(event: int):
	
	# We first check to see if the user wishes to close the program
	if event == DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
		get_tree().quit()
	
	if event == DisplayServer.WINDOW_EVENT_MOUSE_ENTER:  # (this does allow the user to "break"
		# the cat--there are no errors, but it can push the cat to get past the speed for which 
		# the increase is more than the decrease)
		
		# We set these to false so that the user cannot force the cat to go off-screen
		responded_bx = false
		responded_sx = false
		responded_by = false
		responded_sy = false
		
		# Now, we begin the reaction
		if x != 0:
			print("x = " + str(x))
			emit_signal("action", 0, x)
			window_mvment = false
			x *= -1
			y *= -1
			window_mvment = false
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			# And add the stress
			stress += stress_incr * 2
			emit_signal("action", 1 + stress, x)
			
		else:
			pass

# Function to figure out if the cat has reached the end, and what to do if it has
func _is_touching_edge():
	
	# Right edge
	if get_window().position.x > screen_size[0] - 110:
		if not responded_bx:
			x = -1
			emit_signal("action", 0, 1)
			window_mvment = false
			responded_bx = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			stress += stress_incr
			emit_signal("action", speed, -1)
	else:
		responded_bx = false
	
	# Left edge
	if get_window().position.x < 10:
		if not responded_sx:
			x = 1
			emit_signal("action", 0, -1)
			window_mvment = false
			responded_sx = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			stress += stress_incr
			emit_signal("action", speed, 1)
	else:
		responded_sx = false
	
	# Top edge
	if get_window().position.y > screen_size[1] - 110:
		if not responded_by:
			y = -1
			emit_signal("action", 0, x)
			window_mvment = false
			responded_by = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			stress += stress_incr
			emit_signal("action", speed, x)
	else:
		responded_by = false
	
	# Bottom edge
	if get_window().position.y <  10:
		if not responded_sy:
			y = 1
			emit_signal("action", 0, x)
			window_mvment = false
			responded_sy = true
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			stress += stress_incr
			emit_signal("action", speed, x)
	else:
		responded_sy = false

func _process(delta: float) -> void:
	_is_touching_edge()
	energy = clampf(energy, ENERGY_MIN, ENERGY_MAX)
	speed = 1 + stress
	print(str(energy) + ", " + str(stress) + ", " + str(range_idle))
	
	#  If actions can/should be taken...
	if window_mvment:
		# Update window position
		get_window().position.x += x * 2 * speed # Later, we can take this coords and plot them
		get_window().position.y += y * 2 * speed
		energy += energy_dlt * (stress + 1)
		
		# Deals with energy when it reaches 0
		if energy <= 0:
			x = 0
			y = 0
			emit_signal("action", 0, 0)
			switch_dir_cd = 2
			stress_decr = 0.02
			energy_dlt = 0.02
		
		# Countdown until the cat randomly changes direction
		if switch_dir_cd > 0:
			switch_dir_cd -= delta
		elif randi_range(0, range_idle) != 0:
			var dir_opts = [-1, 1]
			x = dir_opts.pick_random()
			y =  dir_opts.pick_random()
			emit_signal("action", 1, x)
			switch_dir_cd = 3
			stress_decr = 0.01
			energy_dlt = -0.01
		else:
			x = 0
			y = 0
			emit_signal("action", 0, 0)
			switch_dir_cd = 3
			stress_decr = 0.02
			energy_dlt = 0.01
			
		# Decreases stress if it is above 0, and increases range_idle (for the same prerequisites)
		if stress > 0:
			stress -= stress_decr
			range_idle = 1 + clampi(roundi(10 * stress - energy), 0, 100)
