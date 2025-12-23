extends AnimatedSprite2D

var dir_to_letters = {-1: "L", 1: "R"}

func _on_movement_action(speed: Variant, direction: Variant) -> void:
	if speed == 0:
		if direction == 0:
			self.play("idle")
		else:
			self.play("damage" + dir_to_letters[direction])
	else:
		self.play("run" + dir_to_letters[direction], 5 * speed/2)
