extends Node


#data that will be needed to keep the game running and store game data
var homeScore := 0
var awayScore := 0
var balls := 0
var strikes := 0
var outs := 0
var isTopofInning = true
var cameraStartPos = Vector2(54, -49)
var timerStarted := false
var hitBall := false
var runnerOn := false
var didSwing := false
var playMade := false
var bat_scene = preload("res://Scenes/bat.tscn")

#get necessary game lements to control the game
@onready var controls = $"../Control/TouchControls"
@onready var count_label := $"../CanvasLayer/CountLabel"
@onready var away_score := $"../CanvasLayer/AwayScore"
@onready var home_score := $"../CanvasLayer/HomeScore"
@onready var playLabel := $"../playLabel"
@onready var kZone := $"../strike Zone"
@onready var camera = %Camera2D
@onready var pitcher = $"../Pitcher"
@onready var batter = $"../batter"
@onready var secondBase = $"../second"
@onready var homePlate = $"../homePlate"
@onready var floor = get_node("../floor")
@onready var bat = get_node("../batter/hands/bat")
@onready var batHands = get_node("../batter/hands")
@onready var gameball
@onready var advance_button = controls.get_node("Advance")
@onready var return_button = controls.get_node("Return")
@onready var swing_button = controls.get_node("Swing")
@export var ghostRunner: PackedScene
var ghost_instance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#disbale the baserunning buttons to start
	advance_button.action = ""
	return_button.action = ""
	swing_button.action = "swing"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkCount() # check the current game count 

	#if the ball hits the Kzone or is hit backwards, reset the scene
	if gameball:
		if gameball.global_position.x <= -175 || kZone.isHit:
			if hitBall:
				playLabel.global_position.x = batter.global_position.x - 15
				playLabel.text = "Foul!"
			if timerStarted == false:
				$Timer.start()
				timerStarted = true


#Checks the current count on the batter
func checkCount():
	
	# 4 balls = walk (they get second base)
	# 3 strieks = strikeout (one out is added)
	if balls == 4:
		playLabel.global_position = kZone.global_position
		playLabel.global_position.y += 7 #adjust the position of where the text will be
		playLabel.global_position.x -= 5
		playLabel.text = "Walk!"
		await get_tree().create_timer(1).timeout
		
		reset()

	elif strikes == 3:
		
		playLabel.global_position = kZone.global_position
		playLabel.global_position.y += 7
		playLabel.global_position.x -= 5
		playLabel.text = "Strikeout!"
		await get_tree().create_timer(1).timeout
		reset()



#Resets the entire play back to the starting state
func reset():
	
	# Check if there's a ghost runner and handle scoring before reset logic
	if runnerOn and ghost_instance and is_instance_valid(ghost_instance):
		var distance_to_home = ghost_instance.global_position.distance_to(batter.HOME)
		
		# If ghost runner is close to home (you can adjust the threshold)
		if distance_to_home < 40.0:
			increaseScore(1)
			ghost_instance.queue_free()
			runnerOn = false
		else:
			if ghost_instance.hasMoved:
				# Move ghost runner back to second base
				ghost_instance.global_position = batter.SECOND_BASE
				ghost_instance.velocity.x = 0
				print(runnerOn)


	# If the batter is safe on second base, spawn a ghost runner
	if batter.isSafe and secondBase.onSecond:
		spawnGhostRunner()
	else:
		#if a ghost runner is not supposed to be on, then remove them
		if !runnerOn and ghost_instance and is_instance_valid(ghost_instance):
			ghost_instance.queue_free()
			
			
	
	#clear the play label text
	playLabel.add_theme_font_size_override("font_size", 16)
	playLabel.text = ""
	
	#stop the pitcher and batter from moving
	pitcher.velocity.x = 0
	batter.velocity.x = 0

	# stop batter movement
	batter.velocity.x = 0
	batter.advancing = false
	batter.returning = false
	batter.hasScored = false
	Input.action_release("advanceRunners")
	Input.action_release("returnRunners")
	Input.action_release("swing")


	#reset Controls
	advance_button.action = ""
	return_button.action = ""
	swing_button.action = "swing"

	
	#if a K or walk occurs, reset the count
	if strikes == 3 || balls == 4 || hitBall:
		if balls == 4:
			spawnGhostRunner()
		
		balls = 0
		strikes = 0
		count_label.text = ""
		count_label.text = "0-0"

	#remove the current ball in the scene if it is still there 
	if gameball:
		gameball.queue_free()
		gameball = null
	
	#reset batter and pitcher positions
	batter.global_position = batter.batterStartPos
	pitcher.global_position = pitcher.pitcherStartPos
	
	#give the batter their bat back if needed 
	if hitBall:
		var new_bat = bat_scene.instantiate()
		
		# Reattach to batter’s hand
		var hand = get_node("../batter/hands")
		hand.add_child(new_bat)
		new_bat.global_position = hand.global_position
		
		# Update your reference and reconnect the new signals
		bat = new_bat
		batter.batInstance = new_bat
		connect_bat_signal(bat)
		pitcher.connect_bat_signal(bat)
	
	#reset batter target and currentBases
	batter.targetbase = batter.SECOND_BASE
	batter.currentBase = batter.HOME
	
	#restart the pitcher timer to throw the ball, reset timer & camera,
	pitcher.restartTimer() 
	timerStarted = false
	floor.hasBounced = false
	hitBall = false
	kZone.isHit = false
	kZone.isStrike = false
	camera.target = null
	didSwing = false
	playMade = false
	camera.global_position = cameraStartPos
	camera.zoom = Vector2(2.3,2.3)
	$Timer.stop()


#When the batter touches homeplate while running, then they score a run. Adds a point
func increaseScore(number):
	if (isTopofInning):
		awayScore += number
		away_score.text = str(awayScore)
	else:
		homeScore += number
		home_score.text = str(homeScore)

#connects the signal that the bat emits to this script
func connect_bat_signal(bat):
	if bat:
		bat.connect("contact_made", Callable(self, "_on_bat_hit"))

#When teh player makes contact with the ball, enable the run controls and disable the swing button
func _on_bat_hit(_body):
	hitBall = true
	advance_button.action = "advanceRunners"
	return_button.action = "returnRunners"
	swing_button.action = ""

#find the ball pitched by the pitcher 
func findBall(ball: RigidBody2D) -> void:
	if ball:
		gameball = ball

#reset after the game timer times out
func _on_timer_timeout() -> void:
	reset()
	

func spawnGhostRunner():
	#	 Instantiate the ghost runner
	ghost_instance = ghostRunner.instantiate()
	# Add it to the current scene (so it appears in the game)
	get_tree().current_scene.add_child(ghost_instance)
	# Set its position to second base
	ghost_instance.global_position = batter.SECOND_BASE
	runnerOn = true
	
