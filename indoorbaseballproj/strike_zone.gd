extends Area2D

#getting reference to the game manager, the ball, and the backstop behind the strikezone 
@onready var gameManager = get_node("../GameManager")
@onready var gameball = get_node("../gameBall")
@export var backstop = CollisionObject2D
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
		isHit = true
	else:
		print("Collision was not with a ball (type: " + str(_body.get_class()) + ")")


#Checks to see if the ball hits the backstop outside of the strike zone to call balls
#if it does, then add a ball to the count and print out the new count 
func _on_static_body_2d_area_entered(_area: Area2D) -> void:
	if(isStrike):
		isHit = true
		return
	else:
		print("Collided with the backstop but is was not a strike")
		gameManager.balls += 1
		isHit = true
		
		
