extends Area2D

@export var hit_force := 500.0   # strength of hit
@export var hit_direction := Vector2.LEFT  # default hit direction

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	print("Bat hit something: " + str(body.name))
	if body is RigidBody2D:
		var ball = body as RigidBody2D
		# Rotate hit_direction by the bat's current rotation
		var force = hit_direction.rotated(global_rotation) * hit_force 
		body.apply_central_impulse(force)
		
		# turn on gravity for the ball
		body.gravity_scale = 1
		
		print("Hit the ball with force: ", force)
	else:
		print("Condition is not being met")
		
