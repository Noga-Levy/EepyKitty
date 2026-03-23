"""
Written in February to March 2026 by Noga Levy.

WIP food bowl that will, eventually, be used as part of an action.
"""

extends Window

var mouse_pressed
var mouse_in_draggable
var offsetx = -55
var offsety = -25


func _ready() -> void:
	# We first ensure that the window does not get covered by other windows
	always_on_top = true
	# Now we make sure that the background is transparent with no borders:
	self.transparent = true
	self.transparent_bg = true
	# Finally, make sure that new windows are not embedded into this one.
	get_viewport().set_embedding_subwindows(false)


func _process(_delta: float) -> void:
	# Later on, when EAT() is called, we'll need the position of the food bowl, so we add the x and
	# y coordinations to global variables and update it every frame.
	Global.food_posx = get_window().position.x - offsetx
	Global.food_posy = get_window().position.y - offsety
