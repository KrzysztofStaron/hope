extends Camera2D


onready var player = get_node("../Player")

func _process(delta):
	position.x = move_toward(position.x, player.position.x, delta * 80)
