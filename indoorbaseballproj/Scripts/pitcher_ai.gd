extends CharacterBody2D

#setting up some pitch settings for the pitcher
@export var gameBall: PackedScene 
@export var timeToPitch = 2.0
@export var direction = Vector2.LEFT

#variables for the pitcher
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 30.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set the timer
	$Timer.wait_time = timeToPitch
	$Timer.start()
	
	print("Inside the pitcher ready function")


func _on_timer_timeout():
	print("Timer is Done!")
	throwPitch()


func throwPitch():
	if gameBall:
		var ball = gameBall.instantiate()
		get_parent().add_child(ball)
		ball.global_position = global_position
		ball.direction = direction.normalized()


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
