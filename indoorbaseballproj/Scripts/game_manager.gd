extends Node


#data that will be needed to keep the game running and store game data
var homeScore := 0
var awayScore := 0
var balls := 0
var strikes := 0
var outs := 0
var isTopofInning = true
var cameraStartPos

#get necessary game lements to control the game
@onready var controls = $"../Control/TouchControls"
@onready var count_label := $"../CanvasLayer/CountLabel"
@onready var away_score := $"../CanvasLayer/AwayScore"
@onready var home_score := $"../CanvasLayer/HomeScore"
@onready var camera = %Camera2D
@onready var pitcher = $"../Pitcher"
@onready var bat = get_node("../batter/hands/bat")
@onready var advance_button = controls.get_node("Advance")
@onready var return_button = controls.get_node("Return")
@onready var swing_button = controls.get_node("Swing")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	advance_button.action = ""
	return_button.action = ""
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkCount() # check the current game count 

#Checks the current count on the batter
func checkCount():
	
	# 4 balls = walk (they get second base)
	# 3 strieks = strikeout (one out is added)
	if balls == 4:
		print("walk")
		reset()
	elif strikes == 3:
		print("strikeout")
		reset()


#Resets the entire play back to the starting state
func reset():
	balls = 0
	strikes = 0
	count_label.text = "Count: 0-0"
	#var ball = get_node("GameBall")
	#ball.queue_free()
	pitcher.restartTimer()


#When the batter touches homeplate while running, then they score a run. Adds a point
func increaseScore():
	if (isTopofInning):
		awayScore += 1
		away_score.text = str(awayScore)
		print("Score increased! Score is now " + str(awayScore))
	else:
		homeScore += 1
		home_score.text = str(homeScore)

#connects the signal that the bat emits to this script
func connect_bat_signal(bat):
	if bat:
		bat.connect("contact_made", Callable(self, "_on_bat_hit"))

#When teh player makes contact with the ball, enable the run controls and disable the swing button
func _on_bat_hit(_body):
	print("GameManager received bat hit signal! Hit object: ", _body.name)
	advance_button.action = "advanceRunners"
	return_button.action = "returnRunners"
	swing_button.action = ""

	
