extends Camera2D

var player

func _ready():
	player = get_node("../Player")
	pass

func _process(delta):
	var direction = (player.get_position() - get_position())
	set_position(position + direction * delta)
	