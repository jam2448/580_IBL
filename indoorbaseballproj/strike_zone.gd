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
	
	if _body is RigidBody2D:
		var ball = _body as RigidBody2D
		ball.gravity_scale = 1
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
		
	else:
		print("Collision was not with a ball (type: " + str(_body.get_class()) + ")")


#Checks to see if the ball hits the backstop outside of the strike zone to call balls
#if it does, then add a ball to the count and print out the new count 

func _on_backstop_body_entered(body: Node2D) -> void:
	if(isStrike):
		print("entered backstop if statement")
		isHit = true
		return
	else:
		if body is RigidBody2D:
			print("ball")
			gameManager.playLabel.global_position = global_position
			gameManager.playLabel.global_position.y += 7
			gameManager.playLabel.global_position.x -= 5
			gameManager.playLabel.text = "Ball!"
			gameManager.balls += 1
			gameManager.count_label.text = str(gameManager.balls) + "-" + str(gameManager.strikes)
			
			#stop the ball from moving 
			var ball = body as RigidBody2D
			ball.gravity_scale = 0
			ball.linear_velocity = Vector2.RIGHT * 3 
			
			isHit = true
			
			
		
		
