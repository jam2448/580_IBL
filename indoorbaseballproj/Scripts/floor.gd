extends StaticBody2D

var hasBounced := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#if the ball hits the back wall
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		hasBounced = true
