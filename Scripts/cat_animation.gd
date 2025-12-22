extends AnimatedSprite2D


func _on_movement_action(speed: Variant, direction: Variant) -> void:
	if speed == 0:
		if direction == "":
			self.play("idle")
		else:
			self.play("damage" + direction)
	else:
		self.play("run" + direction, 5 * speed/2)
