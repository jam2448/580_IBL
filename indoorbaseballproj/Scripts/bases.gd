extends Area2D

#get a reference to the batter script
@onready var batter = get_node("../batter")
@onready var pitcher = get_node("../Pitcher")
@onready var gameManager = get_node("../GameManager")
@onready var timer = gameManager.get_node("Timer")


var onSecond = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(pitcher.isFielded == true):
		set_collision_mask_value(3, true)
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
	
	if self.name == "second" && _body == batter:
		onSecond = true
	else:
		onSecond == false
	
	
	if _body == batter and gameManager.hitBall:
		batter.isSafe = true
		gameManager.playLabel.global_position.x = batter.global_position.x
		gameManager.playLabel.text = "Safe!"
	elif _body == pitcher and pitcher.isFielded and global_position == batter.targetbase:
		await get_tree().process_frame 
		if not batter.isSafe:
			gameManager.playLabel.global_position.x = batter.targetbase.x
			gameManager.playLabel.text = "Out!"
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
		else:
			gameManager.playLabel.text = "Safe!"
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
	else:
		pass
	




func _on_safe_area_body_exited(body: Node2D) -> void:
	if body == batter:
		batter.isSafe = false
		
		
	gameManager.playLabel.text = " "
