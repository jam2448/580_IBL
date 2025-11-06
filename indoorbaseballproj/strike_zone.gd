extends Area2D

#getting reference to the game manager, the ball, and the backstop behind the strikezone 
@onready var gameManager = get_node("../GameManager")
@onready var gameball = get_node("../gameBall")
var direction = Vector2.DOWN

var isStrike := false #flag for determing strikes
var isHit := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# Checks to see if the pitch hits the strike zone, if so add a strike to the count 
func _on_body_entered(_body: Node2D) -> void:
	
	if _body is RigidBody2D && gameManager.hitBall == false && isHit == false:
		
		#of the ball hits the ground before hitting the backstop, it is automatically a ball
		if(gameManager.floor.hasBounced):
			_on_backstop_body_entered(_body)
		
		#stop the ball and call a strike
		var ball = _body as RigidBody2D
		ball.set_collision_mask_value(2,false)
		ball.gravity_scale = 0
		ball.linear_velocity = Vector2.RIGHT
		isStrike = true
		gameManager.strikes += 1
		gameManager.count_label.text = str(gameManager.balls) + "-" + str(gameManager.strikes)
		
		#move the playlabel and tell the batter that a strike was called
		gameManager.playLabel.global_position = global_position
		gameManager.playLabel.global_position.y += 7
		gameManager.playLabel.global_position.x -= 5
		gameManager.playLabel.text = "Strike!"
		isHit = true
		


#Checks to see if the ball hits the backstop outside of the strike zone to call balls
#if it does, then add a ball to the count and print out the new count 

func _on_backstop_body_entered(body: Node2D) -> void:
	if(isStrike == false && gameManager.hitBall == false && isHit == false):
		
		#call a ball
		if body is RigidBody2D:
			body.set_collision_mask_value(2,false)
			gameManager.playLabel.global_position = global_position
			gameManager.playLabel.global_position.y += 7
			gameManager.playLabel.global_position.x -= 5
			gameManager.playLabel.text = "Ball!"
			gameManager.balls += 1
			gameManager.count_label.text = str(gameManager.balls) + "-" + str(gameManager.strikes)
			
			#stop the ball from moving 
			var ball = body as RigidBody2D
			ball.linear_velocity = Vector2.RIGHT
			ball.gravity_scale = 0
			
			isHit = true
			
			
		
		
