extends AnimatedSprite

var desiredAnimation = ""
var currentAnimationPriority = 0
var desiredAnimationPriority = 0
var desiredFlipH = false
var playedAtleastOnce = false

func _ready():
	play()
	pass
	
func animation_finished ():
	print("A")

func setDesiredAnimation(_desiredAnimation):
	desiredAnimation = _desiredAnimation
#	desiredAnimationPriority = computeAnimationPriority(desiredAnimation)
	playedAtleastOnce = false
	
func setDesiredFlipH(_desiredFlipH):
	desiredFlipH = _desiredFlipH

func computeAnimationvalue(delta):
	animation = desiredAnimation
	flip_h = desiredFlipH

func _on_AnimatedSprite_animation_finished():
	playedAtleastOnce = true
	pass # replace with function body
