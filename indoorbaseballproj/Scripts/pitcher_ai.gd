extends CharacterBody2D

#References to the game ball, the batter's bat, time to pitch and direction to pitch the ball
@export var gameBall: PackedScene 
@export var timeToPitch = 2.0
@export var direction = Vector2.LEFT
@onready var bat = get_node("../batter/hands/bat")

#variables for the pitcher
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 30.0
@onready var releasePoint = $ReleasePoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set the timer
	$Timer.wait_time = timeToPitch
	$Timer.start()
	
	#when the bat is instantiated, then connect connect the signal to this script
	if bat:
		bat.connect("contact_made", Callable(self, "_on_bat_hit"))
 
#When the time to potch timer is done then pitch the ball
func _on_timer_timeout():
	throwPitch()


func throwPitch():
	#as long as the gameball is not null, instantiate it at the release point and make it travel to the pitch direction
	if gameBall:
		var ball = gameBall.instantiate()
		releasePoint.add_child(ball)
		ball.global_position = releasePoint.global_position
		var shoot_direction = releasePoint.transform.x.normalized()
		ball.direction = shoot_direction


func _physics_process(delta: float) -> void:
	# allows the player to jump (will remove for offense later)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = 0
	move_and_slide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
#Restart the timer 
func restartTimer():
	$Timer.start()

 #wwhen the bat emits the signal, make the Ai chase after the ball
func _on_bat_hit(_body):
	chaseBall()


func chaseBall():
	pass
