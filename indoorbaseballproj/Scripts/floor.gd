extends StaticBody2D

var hasBounced := false

#if the ball hits the floor, let the game know that it has
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		hasBounced = true
