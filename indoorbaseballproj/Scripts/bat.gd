extends Area2D

#Bat Variables
@export var hit_force := 750.0
@export var hit_direction := Vector2.LEFT

signal contact_made(body) 


#external variables
@onready var gameManager = get_node("/root/Node2D/GameManager")
@onready var camera = get_node("../../../Camera2D")


# when the bat hits something
func _on_body_entered(body: Node2D) -> void:
	emit_signal("contact_made", body)

	#if the bat hits the ball then make the camera follow the ball 
	#make the ball jump off the bat and move 
	# add gravity to the ball
	#Reset balls and strikes 
	if body is RigidBody2D:
		var ball = body as RigidBody2D
		camera.target = ball
		
		var force = hit_direction.rotated(global_rotation) * hit_force
		ball.apply_central_impulse(force)
		
		if ball.linear_velocity.length() > 750.0:
			ball.linear_velocity = ball.linear_velocity.normalized() * 750.0
			print(ball.linear.velocity)
		
		body.gravity_scale = 1
		gameManager.balls = 0
		gameManager.strikes = 0
		gameManager.count_label.text = ""
		gameManager.count_label.text = "0-0"

		# Wait a short moment before dropping the bat
		await get_tree().create_timer(0.2).timeout
		drop_bat()

# delete the bat from the scene
func drop_bat() -> void:
	queue_free()
