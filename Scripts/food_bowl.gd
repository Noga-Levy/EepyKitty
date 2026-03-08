extends Window

func _ready() -> void:
	# We first ensure that the window does not get covered by other windows
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	# Next, we detect if the user wishes to close the window, for which we direct it to a function
	# that deletes the root node
	self.close_requested.connect(_close_window)
	# Now we make sure that the background is transparent:
	self.transparent = true
	self.transparent_bg = true
	# Finally, make sure that new windows are not embedded into this one.
	get_viewport().set_embedding_subwindows(false)
	


func _close_window():
	self.queue_free()
