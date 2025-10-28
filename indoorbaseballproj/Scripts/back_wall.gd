extends StaticBody2D

@onready var gameManager = %GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	



func _on_area_2d_body_entered(body: Node2D) -> void:
	if (gameManager.strikes == 2):
		gameManager.strikes = 2
	else:
		gameManager.strikes += 1
	
	gameManager.count_label.text = ""
	gameManager.count_label.text = str(gameManager.balls) + "-" + str(gameManager.strikes)
	gameManager.reset()
	
	
