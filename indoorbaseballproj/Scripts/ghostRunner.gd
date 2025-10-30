extends Sprite2D

#get a gamemanager reference
@onready var gameManager = get_node("../GameManager")

var speed = 35.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0.3
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gameManager.isHit: 
		pass
