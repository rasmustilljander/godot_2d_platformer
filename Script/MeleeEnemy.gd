extends KinematicBody2D

var player

var VELOCITY = 1 # TODO 
var GRAVITY = 10 # TODO 
var JUMP = 10 # TODO 
var velocity = Vector2()

func _ready():
	player = get_node("../Player")

func _process(delta):
	var direction = (player.get_position() - get_position())
	if(direction.x > 0):
		velocity.x += VELOCITY
	elif(direction.x < 0):
		velocity.x -= VELOCITY
	# Jump timer
	#if(direction.y > 0):
	#	velocity.y -= JUMP
	
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2(1,0))