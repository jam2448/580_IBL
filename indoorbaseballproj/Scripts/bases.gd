extends Area2D

#get a reference to the batter script
@onready var batter = get_node("../batter")
@onready var pitcher = get_node("../Pitcher")
@onready var gameManager = get_node("../GameManager")
@onready var timer = gameManager.get_node("Timer")
@onready var safeArea = $safeArea
@onready var out_sound: AudioStreamPlayer2D = $OutSound
@onready var increase_score: AudioStreamPlayer2D = $IncreaseScore
@onready var safe_sound: AudioStreamPlayer2D = $SafeSound

var onSecond = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# If the pitcher is standing on this base AND has fielded the ball
	if gameManager.playMade:
		return
	
	if pitcher and pitcher.isFielded and safeArea.get_overlapping_bodies().has(pitcher):
		if not batter.isSafe && global_position.distance_to(batter.targetbase) < 10:
			gameManager.playLabel.global_position = batter.targetbase  + Vector2(-15, -20)
			gameManager.playMade = true
			gameManager.playLabel.text = "Out!"
			out_sound.play() #play the sound
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
	pass

# update score each time the player touches home plate as long as it is not the most recent base that is touched
func _on_body_entered(_body: Node2D) -> void:
	if self.name == "homePlate" && batter.currentBase != self.position:
		gameManager.increaseScore(1)
		batter.hasScored = true
		increase_score.play(0.01)
		#gameManager.reset()
		
	#if the ghost runner scores, add the score and delete them
	if self.name == "homePlate" && _body.name == "GhostRunner":
		gameManager.increaseScore(1)
		gameManager.runnerOn = false
		gameManager.ghost_instance.queue_free()
		increase_score.play(0.01)
		print("ghost runner scored!")




func _on_safe_area_body_entered(_body: Node2D) -> void:
	
	if gameManager.playMade:
		return
	#if this is second base, let the game know that the batter is on second base 
	if self.name == "second" && _body == batter:
		onSecond = true
		gameManager.runnerOn = true
		safe_sound.play()
		
	#if the batter is on a base when the ball is hit, call them safe
	if _body == batter and gameManager.hitBall:
		batter.isSafe = true
		gameManager.playLabel.global_position = batter.global_position + Vector2(0, -20)
		gameManager.playLabel.text = "Safe!"
		
	elif _body == pitcher and pitcher.isFielded and global_position.distance_to(batter.targetbase) < 10:
		#if the pitcher touches the base that the batter is running to call them out and reset
		await get_tree().process_frame 
		if batter.isSafe == false:
			gameManager.playLabel.global_position = batter.targetbase  + Vector2(-15, -20)
			gameManager.playLabel.text = "Out!"
			gameManager.playMade = true
			out_sound.play() #play the sound
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
		else:
			#Otherwise the batter is safe. Reset at the end 
			gameManager.playLabel.global_position = batter.global_position + Vector2(0, -20)
			gameManager.playLabel.text = "Safe!"
			gameManager.playMade = true
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
	else:
		pass
	


func _on_safe_area_body_exited(body: Node2D) -> void:
	if body == batter:
		batter.isSafe = false
	onSecond = false
	gameManager.playLabel.text = " "
