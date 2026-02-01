"""
Written in December 2025 to February of 2026 by Noga Levy.

cat_animation.gd, as the name suggests, animates the cat depending on the information given in the
"action" signal, sent by window_movement.gd.
"""

extends AnimatedSprite2D

var dir_to_letters = {-1: "L", 1: "R"}

func _on_movement_action(speed: Variant, direction: Variant) -> void:
	if direction == 0:
		self.play("idle")
	elif speed == 0:
		self.play("damage" + dir_to_letters[direction])
	else:
		self.play("run" + dir_to_letters[direction], 5 * speed/2)
