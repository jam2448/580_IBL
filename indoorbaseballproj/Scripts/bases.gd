extends Area2D

#get a reference to the batter script
@onready var batter = get_node("../batter")
@onready var pitcher = get_node("../Pitcher")
@onready var gameManager = get_node("../GameManager")
@onready var timer = gameManager.get_node("Timer")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# update score each time the player touches home plate as long as it is not the most recent base that is touched
func _on_body_entered(_body: Node2D) -> void:
	if self.name == "homePlate" && batter.currentBase != self.position || self.name == "homePlate" && _body.name == "GhostRunner":
		gameManager.increaseScore()
		
		if _body.name == "GhostRunner":
			_body.queue_free()



func _on_safe_area_body_entered(_body: Node2D) -> void:
	
	if _body == batter && gameManager.hitBall:
		batter.isSafe = true
		gameManager.playLabel.global_position.x = batter.global_position.x
		gameManager.playLabel.text = "Safe!"
	
	# if the pitcher enters the base dn
	if _body == pitcher && pitcher.isFielded == true && self.global_position == batter.targetbase:
		#await get_tree().process_frame  # wait one frame to let batter.isSafe update
		print("Pitcher tagged base")
		
		if batter.isSafe == false:
			print("The batter is out. resetting.....")
			gameManager.playLabel.global_position.x = batter.targetbase.x
			gameManager.playLabel.text = "Out!"
			timer.start()
		else:
			gameManager.playLabel.text = ""
			gameManager.playLabel.text = "Safe!"
			print("Batter is safe")
			timer.start()
	else: 
		print("no one entered safe area")


func _on_safe_area_body_exited(body: Node2D) -> void:
	if body == batter:
		batter.isSafe = false
		
		
	gameManager.playLabel.text = " "
