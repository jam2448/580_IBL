extends Area2D

#get a reference to the batter script
@onready var batter = get_node("../batter")
@onready var pitcher = get_node("../Pitcher")
@onready var gameManager = get_node("../GameManager")
@onready var timer = gameManager.get_node("Timer")
@onready var safeArea = $safeArea

var onSecond = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# If the pitcher is standing on this base AND has fielded the ball
	if gameManager.playMade:
		return
	
	if pitcher and pitcher.isFielded and safeArea.get_overlapping_bodies().has(pitcher):
		if not batter.isSafe && global_position.distance_to(batter.targetbase) < 10:
			gameManager.playLabel.global_position.x = batter.targetbase.x 
			gameManager.playMade = true
			gameManager.playLabel.text = "Out!"
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
	pass

# update score each time the player touches home plate as long as it is not the most recent base that is touched
func _on_body_entered(_body: Node2D) -> void:
	if self.name == "homePlate" && batter.currentBase != self.position:
		gameManager.increaseScore(1)
		batter.hasScored = true
		#gameManager.reset()
		
	#if the ghost runner scores, add the score and delete them
	if self.name == "homePlate" && _body.name == "GhostRunner":
		gameManager.increaseScore(1)
		gameManager.runnerOn = false
		gameManager.ghost_instance.queue_free()
		print("ghost runner scored!")




func _on_safe_area_body_entered(_body: Node2D) -> void:
	
	if gameManager.playMade:
		return
	#if this is second base, let the game know that the batter is on second base 
	if self.name == "second" && _body == batter:
		onSecond = true
		gameManager.runnerOn = true
		
	#if the batter is on a base when the ball is hit, call them safe
	if _body == batter and gameManager.hitBall:
		batter.isSafe = true
		gameManager.playLabel.global_position.x = batter.targetbase.x 
		gameManager.playLabel.text = "Safe!"
	elif _body == pitcher and pitcher.isFielded and global_position.distance_to(batter.targetbase) < 10:
		#if the pitcher touches the base that the batter is running to call them out and reset
		await get_tree().process_frame 
		if batter.isSafe == false:
			gameManager.playLabel.global_position.x = batter.targetbase.x 
			gameManager.playLabel.text = "Out!"
			gameManager.playMade = true
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
		else:
			#Otherwise the batter is safe. Reset at the end 
			gameManager.playLabel.text = "Safe!"
			print("batter is safe (bases else)")
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
