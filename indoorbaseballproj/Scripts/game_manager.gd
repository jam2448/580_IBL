extends Node


#data that will be needed to keep the game running and store game data
var homeScore := 0
var awayScore := 0
var balls := 0
var strikes := 0
var isTopofInning = true

#get necessary game lements to control the game
@onready var count_label = $CountLabel
@onready var away_score = $AwayScore
@onready var home_score = $HomeScore


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkCount()
	

func checkCount():
	#print("Count is: " + str(balls) + "-" + str(strikes))
	#count_label.text += str(balls) + "-" + str(strikes)
	if balls == 4:
		print("walk")
		reset()
	elif strikes == 3:
		print("strikeout")
		reset()


func reset():
	balls = 0
	strikes = 0
	count_label.text = "Count: 0-0"

func increaseScore():
	if (isTopofInning):
		awayScore += 1
		away_score.text = str(awayScore)
		print("Score increased! Score is now " + str(awayScore))
	else:
		homeScore += 1
		home_score.text = str(homeScore)
	
