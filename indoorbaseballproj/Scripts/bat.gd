extends Area2D

@export var hit_force := 550.0   # strength of hit
@export var hit_direction := Vector2.LEFT  # default hit direction
@onready var gameManager = get_node("/root/Node2D/GameManager")
@onready var camera = get_node("../../../Camera2D")

func _on_body_entered(body: Node2D) -> void:
	print("Bat hit something: " + str(body.name))
	var label = gameManager.get_node("CountLabel") as Label
	if body is RigidBody2D:
		var ball = body as RigidBody2D
		camera.target = ball  # Assign camera follow target
		# Rotate hit_direction by the bat's current rotation
		var force = hit_direction.rotated(global_rotation) * hit_force 
		body.apply_central_impulse(force)
		
		# turn on gravity for the ball
		body.gravity_scale = 1
		#reset the count in the gamemanager
		gameManager.balls = 0
		gameManager.strikes = 0
		gameManager.reset()
