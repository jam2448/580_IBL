extends CharacterBody2D


const SPEED = 30.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var advancing = false
var returning = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if advancing:
		velocity.x = SPEED
	elif returning:
		velocity.x = -SPEED
	else:
		velocity.x = 0
	move_and_slide()
	
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
