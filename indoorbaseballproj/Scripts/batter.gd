extends CharacterBody2D

# Variables to help/track player movement
const SPEED = 35.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var advancing = false
var returning = false
var batterStartPos : Vector2

# Variables for the swinging
var swinging = false
var swing_speed = 3.0              # how fast the bat swings
var swing_angle = deg_to_rad(-275)   # swing arc
var swing_progress := 0.0
var rest_rotation := 0.0

# Get the references for the bases that the player needs to go to
@onready var SECOND_BASE = get_node("../second").global_position
@onready var HOME = get_node("../homePlate").global_position
@onready var controls = get_node("../Control/TouchControls")
@onready var gameManager = get_node("%GameManager")
@onready var hitRange = $Area2D
@onready var out_sound: AudioStreamPlayer2D = $OutSound
@onready var run_sound: AudioStreamPlayer2D = $RunSound

# Reference to the bat
@export var batScene: PackedScene
var batInstance: Node2D

# Set a reference to a target base and current base 
var targetbase : Vector2
var currentBase: Vector2
var isSafe := false
var hasScored := false

# Set the current and target bases when the game loads 
func _ready() -> void:
	targetbase = SECOND_BASE
	currentBase = HOME
	batInstance = batScene.instantiate()
	var batPoint = $hands
	batPoint.add_child(batInstance)
	rest_rotation = batInstance.rotation  # save default position
	batterStartPos = global_position
	gameManager.connect_bat_signal(batInstance)


func _physics_process(delta: float) -> void:
	# Apply gravity
	
	#once the ball is fielded allow the batter to get hit by tha ball
	if(gameManager.pitcher.isFielded):
		hitRange.set_collision_mask_value(3, true)
	
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Move toward bases
	if Input.is_action_pressed("advanceRunners"):
		move_right()
		var direction = (targetbase - global_position).normalized()
		velocity.x = direction.x * SPEED
	elif Input.is_action_pressed("returnRunners"):
		move_left()
		var direction = (currentBase - global_position).normalized()
		velocity.x = direction.x * SPEED
	else:
		stop_move_left()
		stop_move_right()
		velocity.x = 0


	# Trigger swing if pressed and not already swinging
	if Input.is_action_just_pressed("swing") and not swinging:
		swinging = true
		swing_progress = 0.0
		$Timer.start()
		
	# Handle swing animation
	if swinging:
		swing_progress += delta * swing_speed
		if swing_progress < 0.5:
			# first half of swing (down/forward)
			batInstance.rotation = rest_rotation + lerp(0.0, swing_angle, swing_progress * 2)
			gameManager.didSwing = true
			
		else:
			# done swinging
			batInstance.rotation = rest_rotation
			swinging = false
			
	move_and_slide()


# Flags to show when the player is moving either left or right
func move_right():
	advancing = true
	
func stop_move_right():
	advancing = false

func move_left():
	returning = true
	
func stop_move_left():
	returning = false


# When a base is touched by the batter, update their current and target bases
func _on_second_body_entered(body: Node2D) -> void:
	if body == self:
		currentBase = SECOND_BASE
		targetbase = HOME 

func _on_home_plate_body_entered(body: Node2D) -> void:
	if body == self:
		currentBase = HOME
		targetbase = SECOND_BASE


func _on_timer_timeout() -> void:
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	if gameManager.playMade:
		return
		
	#if the batter gets hit with the ball they are out 
	if  body is RigidBody2D && gameManager.pitcher.hasThrown == true && isSafe == false:
		gameManager.playLabel.global_position = global_position + Vector2(0, -20)
		gameManager.playLabel.text = "OUT!"
		out_sound.play()
		gameManager.playMade = true
		await get_tree().create_timer(1).timeout
		gameManager.reset()
		
		
