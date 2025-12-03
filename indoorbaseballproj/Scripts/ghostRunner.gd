extends CharacterBody2D

# Get references after the scene is ready
@onready var spawn_sound: AudioStreamPlayer2D = $SpawnSound
@onready var gameManager = get_node("../GameManager")
@onready var second: Node2D = null
var isSafe := true
var homePlate
var speed = 35.0
var hasMoved := false

func _ready() -> void:
	modulate.a = 0.5
	spawn_sound.play()

	# Make sure the GameManager reference exists first
	if gameManager:
		# Wait until the batter is also ready (in case it was instantiated later)
		await get_tree().process_frame
		second = gameManager.batter.get_node("../second")
		homePlate = gameManager.batter.HOME

func _process(delta: float) -> void:
	
	#if the ball is hit and the ball hits the ground, run home and try to score 
	if gameManager && gameManager.hitBall && gameManager.pitcher.floor.hasBounced == true:
		if second:
			hasMoved = true
			var direction = (homePlate - global_position).normalized()
			velocity.x = direction.x * speed 
		
	
	move_and_slide()
