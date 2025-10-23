extends CharacterBody2D

# Variables to help/track player movement
const SPEED = 30.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var advancing = false
var returning = false
var batterStartPos : Vector2

# Variables for the swinging
var swinging = false
var swing_speed = 3.0              # how fast the bat swings
var swing_angle = deg_to_rad(-275)   # swing arc
var swing_progress = 0.0
var rest_rotation := 0.0

# Get the references for the bases that the player needs to go to
@onready var SECOND_BASE = get_node("../second").global_position
@onready var HOME = get_node("../homePlate").global_position
@onready var controls = get_node("../Control/TouchControls")
@onready var gameManager = get_node("%GameManager")

# Reference to the bat
@export var batScene: PackedScene
var batInstance: Node2D

# Set a reference to a target base and current base 
var targetbase : Vector2
var currentBase: Vector2
var isSafe := false

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
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Move toward bases
	if Input.is_action_pressed("advanceRunners"):
		var direction = (targetbase - global_position).normalized()
		velocity.x = direction.x * SPEED
	elif Input.is_action_pressed("returnRunners"):
		var direction = (currentBase - global_position).normalized()
		velocity.x = direction.x * SPEED
	else:
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
