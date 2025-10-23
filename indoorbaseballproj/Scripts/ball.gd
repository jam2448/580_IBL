extends RigidBody2D

#set the speed & direction of the ball
@export var speed = 200.0

#@onready var timer = $Timer
var direction = Vector2.LEFT


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_velocity = direction.normalized() * speed
	set_collision_mask_value(1, false)
