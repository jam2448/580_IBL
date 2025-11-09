extends StaticBody2D

@onready var gameManager = %GameManager


func _on_area_2d_body_entered(body: Node2D) -> void:
	#if there are two strikes dont add one. Otherwise Add one and reset
	if (gameManager.strikes == 2):
		gameManager.strikes = 2
	else:
		gameManager.strikes += 1
	
	#print a new count and reset say foul ball
	gameManager.playLabel.global_position = body.global_position
	gameManager.playLabel.text = "Foul Ball!"
	gameManager.count_label.text = ""
	gameManager.count_label.text = str(gameManager.balls) + "-" + str(gameManager.strikes)
	gameManager.reset()
	
	
