extends Area2D

#get a reference to the batter script
@onready var batter = get_node("../batter")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# update score each time the player touches home plate as long as it is not the most recent base that is touched
func _on_body_entered(body: Node2D) -> void:
	if self.name == "homePlate" && batter.currentBase != self.position:
		var gameManager = get_node("../GameManager")
		gameManager.score += 1
		print("You scored a run. You now have " + str(gameManager.score))
