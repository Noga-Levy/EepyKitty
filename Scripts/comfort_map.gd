"""
Written in May to June of 2026 by Noga Levy.

This program, attached to comfort_map.tscn, works to provide a basic visualization of the comfort
map.
"""

extends Window


var screen_size  # Will contain the user's screen dimensions.

var update_cd = 0  # Countdown til the grid updates itself (as we do not want to overwhelm godot)

var current_labels = []  # current_labels is used to control all of the Labels in the scene.

const LABEL_THEME = preload("res://Themes/label_theme.tres")  # LABEL_THEME merely sets the size of 
															  # the text to 10px.

var count = 0  # Count gives us the index of the current_labels' label that corresponds to the value
			   # at comfort_grid's same index (as current_labels will be designed in _ready to have
			   # that particular likeness to the dictionary).
			
const ROUND_DP = 0.001 # Later, when we have to round--such as when we are putting the comfort 
					   # values into labels--we will use this constant as the number of decimal 
					   # places to keep.

const MAX_COLOR_VALUE = 1  # Additionally, when we set the labels, we will have to ensure that the
						   # RGB value does not under or overflow; thus, we set a constant to the
						   # maximum and, as seen below, minimum value.
const MIN_COLOR_VALUE = 0

var RGB_value_dlt = 0  # When we need to change the color of a label, we will do it in increments of
					   # RGB_value_dlt

var screen_dimensions: Vector2  # Used later in the program

func _ready() -> void:
	# We set up the window, size and embedding:
	screen_size = DisplayServer.screen_get_size()
	self.size = screen_size
	get_viewport().set_embedding_subwindows(false)
	self.title = "EepyKitty - Comfort Grid Visualizer"
	
	# Now, we must set up our comfort grid--the real "emergent behavior" part of this AI.
	# To do that, we find the dimensions of the current screen so we can create a grid with a global
	# dictionary
	screen_dimensions = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	
	for i in range(0, screen_dimensions.x + Global.GRID_SQUARE_SIZE, Global.GRID_SQUARE_SIZE):
		for j in range(0, screen_dimensions.y + Global.GRID_SQUARE_SIZE, Global.GRID_SQUARE_SIZE):
			# Grids will be identified by their lowest value. So, the coordinates (10, 90) would,
			# for example, be in the grid [0, 50].
			var current_grid = {[i, j] : 0}
			Global.comfort_grid.merge(current_grid) # This value will be updated as the program 
													# runs.
	
	# With comfort_grid, we can create a visualization, where each label has a corresponding square
	for k in Global.comfort_grid:
		var x = k[0]
		var y = k[1]
		
		var new_Text = Label.new()
		
		new_Text.position = Vector2(x, y)
		# We set the text to the comfort value of the square (just in case some values have already
		# changed), rounded so the numbers don't overlap
		new_Text.text = str(snappedf(Global.comfort_grid[[x, y]], ROUND_DP))
		
		# Now, we set the design aspects of the text, defining the size and theme.
		const TEXT_WIDTH = 100  # We leave the width and heights as constansts, since the number of
		const TEXT_HEIGHT = 30  # Labels needed will change with the screen, keeping us from
								# changing the size.
		new_Text.size = Vector2(TEXT_WIDTH, TEXT_HEIGHT)
		new_Text.theme = LABEL_THEME
		
		add_child(new_Text)
		current_labels.append(new_Text)


func _process(_delta: float) -> void:
	count = 0
	for i in Global.comfort_grid:
		# We change the color and update the labels accordingly:
		if current_labels[count].text == str(snappedf(Global.comfort_grid[i], ROUND_DP)):
			# As time goes on, the red hue of the square fades away as it becomes less recently
			# updated
			RGB_value_dlt = 0.004  # 0.004 creates the smoothest fading effect, without taking too
								   # long to fade.
		else:
			current_labels[count].text = str(snappedf(Global.comfort_grid[i], ROUND_DP))
			# When a square is updated, though, its red hue increases dramatically to indicate  
			# the change.
			RGB_value_dlt = -0.0375  # Similar to 0.004, experimentation showed that decreasing by
									 # increments of 0.0375 produced the smoothest effect.
		
		# We now enact the change:
		current_labels[count].modulate.g += RGB_value_dlt
		current_labels[count].modulate.b += RGB_value_dlt
		
		# Now, before we loop to the next square/label, we ensure that the b and g values of the
		# label does not over or underflow.
		current_labels[count].modulate.b = clamp(current_labels[count].modulate.b, MIN_COLOR_VALUE,
												 MAX_COLOR_VALUE)
		current_labels[count].modulate.g = clamp(current_labels[count].modulate.g, MIN_COLOR_VALUE,
												 MAX_COLOR_VALUE)
		count += 1
