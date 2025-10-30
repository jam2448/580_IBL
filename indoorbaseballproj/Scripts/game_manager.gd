extends Node


#data that will be needed to keep the game running and store game data
var homeScore := 0
var awayScore := 0
var balls := 0
var strikes := 0
var outs := 0
var isTopofInning = true
var cameraStartPos = Vector2(55, -31)
var timerStarted := false
var hitBall := false

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
@onready var floor = get_node("../floor")
@onready var bat = get_node("../batter/hands/bat")
@onready var batHands = get_node("../batter/hands")
@onready var gameball
@onready var advance_button = controls.get_node("Advance")
@onready var return_button = controls.get_node("Return")
@onready var swing_button = controls.get_node("Swing")
var ghostRunner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#disbale the baserunning buttons to start
	advance_button.action = ""
	return_button.action = ""
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkCount() # check the current game count 
	
	#update_camera_zoom()
	#if the ball hits the Kzone or is hit backwards, reset the scene
	if gameball:
		if gameball.global_position.x <= -165 || kZone.isHit:
			if timerStarted == false:
				$Timer.start()
				timerStarted = true


#Checks the current count on the batter
func checkCount():
	
	# 4 balls = walk (they get second base)
	# 3 strieks = strikeout (one out is added)
	if balls == 4:
		reset()
		print("walk")
	elif strikes == 3:
		reset()
		print("strikeout")


#Resets the entire play back to the starting state
func reset():
	
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


	#reset Controls
	advance_button.action = ""
	return_button.action = ""
	Input.flush_buffered_events()
	swing_button.action = "swing"

	
	#if a K or walk occurs, reset the count
	if strikes == 3 || balls == 4:
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
		var bat_scene = preload("res://Scenes/bat.tscn")
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
	camera.global_position = cameraStartPos
	$Timer.stop()


#When the batter touches homeplate while running, then they score a run. Adds a point
func increaseScore():
	if (isTopofInning):
		awayScore += 1
		away_score.text = str(awayScore)
		print("Score increased! Score is now " + str(awayScore))
	else:
		homeScore += 1
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
	
#func update_camera_zoom() -> void:
	#var screen_rect = Rect2(
		#camera.get_screen_center_position() - (camera.get_viewport_rect().size / 2) * camera.zoom,
		#camera.get_viewport_rect().size * camera.zoom
	#)
#
	## If batter is off-screen, zoom out smoothly
	#if not screen_rect.has_point(batter.global_position):
		#camera.zoom = camera.zoom.lerp(Vector2(1.5, 1.5), 0.05)
	#else:
		#camera.zoom = camera.zoom.lerp(Vector2(2.2, 2.2), 0.05)
