extends StaticBody2D

@onready var gameManager = get_node("%GameManager")

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	#if the ball hits the wall on the fly, then declare a homerun
	if body is RigidBody2D && gameManager.floor.hasBounced == false:
		gameManager.playLabel.global_position = body.global_position
		gameManager.playLabel.add_theme_font_size_override("font_size", 24)
		gameManager.playLabel.text = "HOMERUN!!!"
		gameManager.pitcher.isChasing = false
		gameManager.pitcher.velocity.x = 0
		
		#if there was a ghost runner on base, adjust the amount of runs accordingly
		if(gameManager.runnerOn == true):
			gameManager.increaseScore(2)
			gameManager.runnerOn = false
			await get_tree().create_timer(1.5).timeout
			gameManager.reset()
			
		else:
			gameManager.increaseScore(1)
			await get_tree().create_timer(1).timeout

			gameManager.reset() #reset at the end
		
