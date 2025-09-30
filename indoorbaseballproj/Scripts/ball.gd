extends RigidBody2D

#set the speed & direction of the ball
@export var speed = 200.0

var direction = Vector2.LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_velocity = direction.normalized() * speed
	set_collision_mask_value(1, false)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_body_entered(_body: Node) -> void:
	print("Made contact with something")
	pass # Replace with function body.
