"""
Written in May of 2026 by Noga Levy.

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


func _ready() -> void:
	# We set up the window, size and embedding:
	screen_size = DisplayServer.screen_get_size()
	self.size = screen_size
	get_viewport().set_embedding_subwindows(false)
	self.title = "EepyKitty - Comfort Grid Visualizer"
	
	# Now, we must set up our comfort grid--the real "emergent behavior" part of this AI.
	# To do that, we find the dimensions of the current screen so we can create a grid with a global
	# dictionary
	var screen_dimensions: Vector2 = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	var grid_square_size = 50
	
	for i in range(0, screen_dimensions.x + grid_square_size, grid_square_size):
		for j in range(0, screen_dimensions.y + grid_square_size, grid_square_size):
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
		new_Text.text = str(snappedf(Global.comfort_grid[[x, y]], 0.001))
		new_Text.size = Vector2(100, 30)
		new_Text.theme = LABEL_THEME
		
		add_child(new_Text)
		current_labels.append(new_Text)


func _process(delta: float) -> void:
	count = 0
	for i in Global.comfort_grid:
		# We change the color and update the labels accordingly:
		if current_labels[count].text == str(snappedf(Global.comfort_grid[i], 0.001)):
			# As time goes on, the red hue of the square fades away as it becomes less recently
			# updated
			current_labels[count].modulate.g += 0.004
			current_labels[count].modulate.b += 0.004
		else:
			current_labels[count].text = str(snappedf(Global.comfort_grid[i], 0.001))
			# When a square is updated, though, its red hue increases dramatically to indicate  
			# the change.
			current_labels[count].modulate.g -= 0.0375
			current_labels[count].modulate.b -= 0.0375
		
		# Now, before we loop to the next square/label, we ensure that the b and g values of the
		# label does not over or underflow.
		current_labels[count].modulate.b = clamp(current_labels[count].modulate.b, 0.0, 1.0)
		current_labels[count].modulate.g = clamp(current_labels[count].modulate.g, 0.0, 1.0)
		count += 1
