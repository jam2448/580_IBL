extends StaticBody2D

@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound
var hasBounced := false

#if the ball hits the floor, let the game know that it has
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		bounce_sound.play(0.02)
		hasBounced = true
