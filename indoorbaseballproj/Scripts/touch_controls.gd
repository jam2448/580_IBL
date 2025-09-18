extends CanvasLayer

@export var player_path: NodePath

@onready var player: CharacterBody2D = get_node(player_path)

@onready var advance = $Advance
@onready var returnRunners = $Return
@onready var swing = $Swing

func _ready():
	print("Found player:", player)  # should print the batter node

#when pressed advance the runner
func _on_advance_pressed() -> void:
	#advance.modulate.a = 0.5
	player.move_right()
	print("advance runners pressesd")

#when pressed stop the runner
func _on_advance_released() -> void:
	#advance.modulate.a = 1.0
	player.stop_move_right()
	print("advance runners released")

# when pressed return the runner 
func _on_return_pressed() -> void:
	#returnRunners.modulate.a = 0.5
	player.move_left()
	print("return runners pressed")


func _on_return_released() -> void:
	#returnRunners.modulate = 1.0
	player.stop_move_left()
	print("return runners released")

#when pressed swing the bat
func _on_swing_pressed() -> void:
	#swing.modulate.a = 0.5
	print("swing pressed")


func _on_swing_released() -> void:
	#swing.modulate.a = 1.0
	print("swing released")
