extends Camera2D

var player
export var threshold = 10

func _ready():
	player = get_node("../Player")
	pass

func _process(delta):
	var direction = (player.get_position() - get_position())
	direction.x = 0
	if(direction.length() > threshold):
		set_position(position + direction * delta)