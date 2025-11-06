extends StaticBody2D

@onready var gameManager = get_node("%GameManager")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D && gameManager.floor.hasBounced == false:
		print("homerun!")
		gameManager.playLabel.global_position = body.global_position
		gameManager.playLabel.text = "HOMERUN!!!"
		gameManager.pitcher.isChasing = false
		gameManager.pitcher.velocity.x = 0

		if(gameManager.runnerOn == true):
			gameManager.increaseScore(2)
			gameManager.runnerOn = false
			await get_tree().create_timer(2).timeout
			gameManager.reset()
			
		else:
			gameManager.increaseScore(1)
			await get_tree().create_timer(1).timeout

			gameManager.reset()
		
