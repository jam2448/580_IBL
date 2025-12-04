extends CanvasLayer

#get the path to the batter in the scene and get it
@export var player_path: NodePath
@onready var player: CharacterBody2D = get_node(player_path)
@onready var player_run: AudioStreamPlayer2D = $PlayerRun

#Get reference to the buttons 
@onready var advance := $Advance
@onready var returnRunners := $Return
@onready var swing := $Swing

#check and see if the buttons are disabled or not. If they are grey them out, if not make them full brighness
func _process(_delta: float) -> void:
	# fade out when disabled (action == "")
	if advance.action == "":
		advance.modulate.a = 0.3
	else:
		advance.modulate.a = 1.0

	if returnRunners.action == "":
		returnRunners.modulate.a = 0.3
	else:
		returnRunners.modulate.a = 1.0

	if swing.action == "":
		swing.modulate.a = 0.3
	else:
		swing.modulate.a = 1.0


# Advance the runner when advance runners is pressed and stop when it is is realeased
func _on_advance_pressed() -> void:
	advance.modulate.a = 0.5
	player.move_right()

func _on_advance_released() -> void:
	advance.modulate.a = 1.0
	player.stop_move_right()


# Return runner to previous base when pressed, and stop when they release
func _on_return_pressed() -> void:
	returnRunners.modulate.a = 0.5
	player.move_left()

func _on_return_released() -> void:
	returnRunners.modulate.a = 1.0
	player.stop_move_left()

#swing
func _on_swing_pressed() -> void:
	swing.modulate.a = 0.5

func _on_swing_released() -> void:
	swing.modulate.a = 1.0
