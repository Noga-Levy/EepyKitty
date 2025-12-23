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

# A random int will be selected from 0 to range_idle to deteremine if the cat will go idle. The 
# larger range_idle is, the less likely
var range_idle = 1  # More stress = higher number

# This will act as the timer until the cat randomly switches direction
var switch_dir_cd = 5

func _ready() -> void:
	# We first ensure that the cat does not get covered by other windows
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	# And then detect window callbacks, such as the mouse entering the window, thus touching the cat
	DisplayServer.window_set_window_event_callback(_window_callback)

# Function for window callbacks
func _window_callback(event: int):
	if event == DisplayServer.WINDOW_EVENT_MOUSE_ENTER:  # (this does allow the user to "break
		#" the cat--there are no errors, but it can push the cat to get past the speed for which 
		# the increase is more than the decrease)
		
		# We set these to false so that the user cannot force the cat to go off-screen
		responded_bx = false
		responded_sx = false
		responded_by = false
		responded_sy = false
		
		# Now, we begin the reaction
		emit_signal("action", 0, x)
		window_mvment = false
		x *= -1
		y *= -1
		window_mvment = false
		await get_tree().create_timer(1).timeout
		window_mvment = true
		switch_dir_cd = 3
		emit_signal("action", 1, x)
		
		# And add the stress
		stress += stress_incr * 2


# Function to figure out if the cat has reached the end, and what to do if it has
func _is_touching_edge():
	
	# Right edge
	if get_window().position.x > screen_size[0] - 110:
		if not responded_bx:
			x = -1
			emit_signal("action", 0, 1)
			window_mvment = false
			responded_bx = true
			window_mvment = false
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			emit_signal("action", 1, -1)
			stress += stress_incr
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
			emit_signal("action", 1, 1)
			stress += stress_incr
	else:
		responded_sx = false
	
	# Top edge
	if get_window().position.y > screen_size[1] - 110:
		if not responded_by:
			y = -1
			emit_signal("action", 0, x)
			window_mvment = false
			responded_by = true
			window_mvment = false
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			emit_signal("action", 1, x)
			stress += stress_incr
	else:
		responded_by = false
	
	# Bottom edge
	if get_window().position.y <  10:
		if not responded_sy:
			y = 1
			emit_signal("action", 0, x)
			window_mvment = false
			responded_sy = true
			window_mvment = false
			await get_tree().create_timer(1).timeout
			window_mvment = true
			switch_dir_cd = 3
			emit_signal("action", 1, x)
			stress += stress_incr
	else:
		responded_sy = false

func _process(delta: float) -> void:
	_is_touching_edge()
	
	#  If actions can/should be taken...
	if window_mvment:
		# Update window position
		get_window().position.x += x * 2 * (1 + stress)
		get_window().position.y += y * 2 * (1 + stress)
		
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
		else:
			x = 0
			y = 0
			emit_signal("action", 0, 0)
			switch_dir_cd = 3
			stress_decr = 0.02
		
		# Decreases stress if it is above 0, and increases range_idle (for the same prerequisites)
		if stress > 0:
			stress -= stress_decr
			range_idle = 1 + roundi(10 * stress)
			print(range_idle)
