extends CharacterBody2D

#Variables to help/track player movement
const SPEED = 30.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var advancing = false
var returning = false

#get the refrences for the bases that the player needs to go to
@onready var SECOND_BASE = get_node("../second").position
@onready var HOME = get_node("../homePlate").position

#set a refrence to a target base and current base 
var targetbase: Vector2
var currentBase: Vector2

#set the current and target bases when the game loads 
func _ready() -> void:
	targetbase = SECOND_BASE
	currentBase = HOME



func _physics_process(delta: float) -> void:
	# allows the player to jump (will remove for offense later)
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#if advance is pressed mnove the batter toward the target base 
	if Input.is_action_pressed("advanceRunners"):
		var direction = (targetbase - global_position).normalized()
		velocity.x = direction.x * SPEED
	
	#if return is pressed move them to the current base
	elif Input.is_action_pressed("returnRunners"):
		var direction = (currentBase - global_position).normalized()
		velocity.x = direction.x * SPEED
	else:
		velocity.x = 0
	move_and_slide()
	
#flags to show when the player is moving either left or right
func move_right():
	advancing = true
	
func stop_move_right():
	advancing = false

func move_left():
	returning = true
	
func stop_move_left():
	returning = false
	
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()

#when a base is touched by the batter, update their current and target bases
func _on_second_body_entered(body: Node2D) -> void:
	if body == self:
		currentBase = SECOND_BASE
		targetbase = HOME

func _on_home_plate_body_entered(body: Node2D) -> void:
	if body == self:
		currentBase = HOME
		targetbase = SECOND_BASE
