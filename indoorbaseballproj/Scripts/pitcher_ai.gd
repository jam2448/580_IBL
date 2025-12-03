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
@onready var out_sound: AudioStreamPlayer2D = $OutSound
@onready var fielded_sound: AudioStreamPlayer2D = $fieldedSound

var currentBall: RigidBody2D = null


#variables for the pitcher
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 70.0
var isChasing := false # is the pitcher chasing the ball?
var isPitched := false #has the pitcher pitched the ball?
var isFielded := false # has the pitcher fielded the ball?
var isReady := true 
var hasThrown := false #has he pitcher thrown the ball outside of piching
var isPickedUp = false #has the piutcher picked up the ball
var pitcherStartPos : Vector2
var outSoundPlayed = false
var fieldedSoundPlayed = false
@onready var releasePoint = $ReleasePoint
@onready var fieldingArea = $FieldingRange

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set the timer
	$Timer.wait_time = timeToPitch
	$Timer.start()
	pitcherStartPos = global_position
	set_collision_mask_value(1, false)
	
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
		currentBall.gravity_scale = randf_range(0.007, 0.075)
		currentBall.speed = randf_range(200, 250)
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
		currentBall.set_collision_mask_value(1,true)
		#if the pitcher contacts the ball before it hits the ground, the batter is out 
		if not floor.hasBounced and not outSoundPlayed:
			outSoundPlayed = true   
			gameManager.playLabel.global_position.x = batter.targetbase.x - 15
			gameManager.playMade = true
			velocity.x = 0
			gameManager.playLabel.text = "Out!"
			out_sound.play()

			await get_tree().create_timer(0.75).timeout
			gameManager.reset()
		
		#if the batter has scored, try and tag the runner
		elif batter.hasScored:
			direction = (batter.global_position - global_position).normalized()
			velocity.x = direction.x * speed
		
		#if the batter is not near the base yet then try to tag the base
		elif batter.global_position.distance_to(batter.targetbase) >= 30 && batter.targetbase == batter.SECOND_BASE:
			direction = (batter.targetbase - global_position).normalized()
			velocity.x = direction.x * speed
		
		#if the batter has already touched second then try to get them out at home
		elif batter.targetbase == batter.HOME:
			#if they are not close to home then try and tag the runner 
			if batter.global_position.distance_to(batter.targetbase) >= 50:
				direction = (batter.global_position - global_position).normalized()
				velocity.x = direction.x * speed
			#if they are close and pitcher is within a reasonable distance, then try and throw the ball home and get them out 
			else:
				if currentBall && not hasThrown && global_position.distance_to(batter.targetbase) < 150:
					currentBall.global_position = releasePoint.global_position
					var throwDirection = (batter.global_position - releasePoint.global_position).normalized()
					var throw_speed = 350.0  # Adjust for your game’s scale
					currentBall.linear_velocity = throwDirection * throw_speed
					isFielded = false
					fieldedSoundPlayed = false
					isChasing = true
					hasThrown = true
					#slow the pitcher down 
					velocity.x = 30
				
		#if none of the above things happen, then run the ball back in 
		else:
			direction = (batter.SECOND_BASE - global_position).normalized()
			velocity.x = direction.x * speed
		
	
	#if the pitcher ia supposed to be chasing the ball, then chase it
	if isChasing:
		await get_tree().create_timer(0.3).timeout
		if currentBall:  # 
			fieldingArea.set_collision_mask_value(3, true)
			direction = (currentBall.global_position - global_position).normalized()
			velocity.x = direction.x * speed
	move_and_slide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#if the ball is fielded and it is the correct ball attach it to the release point
	if isFielded && currentBall:
		if !fieldedSoundPlayed && floor.hasBounced:
			fielded_sound.play()
			fieldedSoundPlayed = true
		currentBall.global_position = releasePoint.global_position
		
		isPickedUp = true
	pass

#Restart the timer 
func restartTimer(): 
	currentBall = null
	fieldingArea.set_collision_mask_value(3, false)
	isFielded = false
	isChasing = false
	hasThrown = false
	outSoundPlayed = false
	fieldedSoundPlayed = false
	$Timer.start()

 #when the bat emits the signal, make the Ai chase after the ball
func _on_bat_hit(_body):
	isChasing = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == currentBall:
		isChasing = false
		isFielded = true
		# Freeze physics so we can move/reparent safely
		#currentBall.freeze = true
		currentBall.linear_velocity = Vector2.ZERO
		currentBall.angular_velocity = 0
	
	#if the pitcher has fielded the ball, and contacts the batter,and the batter is not safe they are out
	if body == batter and isFielded and not batter.isSafe:
		if not outSoundPlayed:
			outSoundPlayed = true  # <-- prevents repeat plays
			gameManager.playMade = true
			velocity.x = 0
			gameManager.playLabel.text = "Out!"
			out_sound.play()
			await get_tree().create_timer(1).timeout
			gameManager.reset()
	
	#if the batter is safe when tagged, then they are safe
	if(body == batter && isFielded && batter.isSafe):
		gameManager.playMade = true
		velocity.x = 0
		gameManager.playLabel.text = "Safe!"
		await get_tree().create_timer(1).timeout
		gameManager.reset()
		
		

#when there is a new bat, then reconnect the signal from the old bat to the new 
func connect_bat_signal(new_bat: Node):
	if new_bat and not new_bat.is_connected("contact_made", Callable(self, "_on_bat_hit")):
		new_bat.connect("contact_made", Callable(self, "_on_bat_hit"))
		bat = new_bat
