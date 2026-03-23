"""
Written in December 2025 to February of 2026 by Noga Levy.

cat_animation.gd, as the name suggests, animates the cat depending on the information given in the
"action" signal, sent by window_movement.gd.
"""

extends AnimatedSprite2D

var dir_to_letters = {-1: "L", 1: "R"}

func _ready() -> void:
	Global.action.connect(_on_movement_action)

func _on_movement_action(speed: Variant, direction: Variant) -> void:
	# If direction is 0, we know it's either idle, sleep, or eat
	if direction == 0:
		# Now we check the speed for our "IDs"
		if speed == 0:
			self.play("idle")
		elif speed == -1:
			self.play("sleep")
		elif speed == -2:
			self.play("eat")
	elif speed == 0:
		self.play("damage" + dir_to_letters[direction])
	else:
		self.play("run" + dir_to_letters[direction], 5 * speed/2)
