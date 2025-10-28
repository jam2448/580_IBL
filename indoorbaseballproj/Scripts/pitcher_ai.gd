extends CharacterBody2D

#References to the game ball, the batter's bat, time to pitch and direction to pitch the ball and batter 
@export var gameBall: PackedScene 
@export var timeToPitch = 2.0
var direction = Vector2.LEFT
@onready var bat = get_node("../batter/hands/bat")
@onready var batter = get_node("../batter")
@onready var gameManager = get_node("%GameManager")
@onready var GMTimer = get_node("../GameManager/Timer")
@onready var floor = get_node("../floor")

var currentBall: RigidBody2D = null


#variables for the pitcher
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 90.0
var isChasing := false
var isPitched := false
var isFielded := false
var isReady := true
var pitcherStartPos : Vector2
@onready var releasePoint = $ReleasePoint
@onready var fieldingArea = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set the timer
	$Timer.wait_time = timeToPitch
	$Timer.start()
	pitcherStartPos = global_position
	
	
	#when the bat is instantiated, then connect connect the signal to this script
	if bat:
		bat.connect("contact_made", Callable(self, "_on_bat_hit"))
		


#When the time to potch timer is done then pitch the ball
func _on_timer_timeout():
	throwPitch()


func throwPitch():
	#as long as the gameball is not null, instantiate it at the release point and make it travel to the pitch direction
	if gameBall:
		currentBall = gameBall.instantiate()
		get_tree().current_scene.add_child(currentBall)
		currentBall.global_position = releasePoint.global_position
		var shoot_direction = releasePoint.transform.x.normalized()
		currentBall.direction = shoot_direction
		isPitched = true
		
		# Tell GameManager about this new ball
		if gameManager:
			gameManager.findBall(currentBall)
			
	
	#stop the timer 
	$Timer.stop()


func _physics_process(delta: float) -> void:
	# aapplies gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#When the ball is fielded, if the ball is caught in the air, then reset
	#if it bounces the ai will run to the base
	if isFielded:
		if floor.hasBounced == false:
			gameManager.playLabel.global_position.x = global_position.x
			gameManager.playLabel.text = "Out!"
			velocity.x = 0
			await get_tree().create_timer(1).timeout
			gameManager.reset()
			
		elif batter.global_position.distance_to(batter.targetbase) >= 15:
			direction = (batter.targetbase - global_position).normalized()
			velocity.x = direction.x * speed
		
	
	#if the pitcher ia supposed to be chasing the ball, then chase it
	if(isChasing):
		fieldingArea.set_collision_mask_value(3, true)
		direction = (currentBall.global_position - global_position).normalized()
		velocity.x = direction.x * speed

	move_and_slide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#if the ball is fielded and it is the correct ball attach it to the release point
	if isFielded && currentBall:
		currentBall.global_position = releasePoint.global_position
	pass

#Restart the timer 
func restartTimer(): 
	currentBall = null
	fieldingArea.set_collision_mask_value(3, false)
	isFielded = false
	isChasing = false
	$Timer.start()

 #when the bat emits the signal, make the Ai chase after the ball
func _on_bat_hit(_body):
	isChasing = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == currentBall:
		isChasing = false
		isFielded = true
		# Freeze physics so we can move/reparent safely
		currentBall.freeze = true
		currentBall.linear_velocity = Vector2.ZERO
		currentBall.angular_velocity = 0
		

func connect_bat_signal(new_bat: Node):
	if new_bat and not new_bat.is_connected("contact_made", Callable(self, "_on_bat_hit")):
		new_bat.connect("contact_made", Callable(self, "_on_bat_hit"))
		bat = new_bat
