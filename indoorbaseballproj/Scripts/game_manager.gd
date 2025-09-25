extends Node


#data that will be needed to keep the game running and store game data
var score = 0
var balls = 0
var strikes = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkCount()
	

func checkCount():
	if balls == 4:
		print("walk")
		balls = 0
	elif strikes == 3:
		print("strikeout")
		strikes = 0
