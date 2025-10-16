extends Camera2D

@export var target: Node2D

func _process(_delta):
	if target and is_instance_valid(target):
		global_position = target.global_position
