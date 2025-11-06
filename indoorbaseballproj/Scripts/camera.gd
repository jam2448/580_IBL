extends Camera2D

@export var target: Node2D          # The ball or object to follow
@export var home_plate: Node2D      # Reference to home plate for distance checks
@export var follow_speed := 5.0     # How smoothly the camera follows the target
var zoom_speed := 2.0       # How quickly the camera zooms in/out
var min_zoom := Vector2(2.2, 2.2)   # Normal zoom when the ball is close
var max_zoom := Vector2(0.75, 0.75)   # Zoomed out when the ball is far
var max_distance := 1000.0       # Distance where zoom is fully maxed out

func _process(delta: float) -> void:
	if not target or not is_instance_valid(target) or not home_plate:
		return

	# Smoothly follow the target
	global_position = target.global_position

	# Calculate distance from home plate to target (ball)
	var distance = home_plate.global_position.distance_to(target.global_position)
	var t = clamp(distance / max_distance, 0.0, 1.0)

	# Calculate target zoom based on distance
	var target_zoom = min_zoom.lerp(max_zoom, t)

	# Smoothly interpolate toward the target zoom
	zoom = zoom.lerp(target_zoom, delta * zoom_speed)

	# Optional: If the target stops moving, slowly return to default zoom
	if target is RigidBody2D and target.linear_velocity.length() < 10:
		zoom = zoom.lerp(min_zoom, delta * (zoom_speed * 0.5))
