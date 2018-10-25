extends KinematicBody2D

const TIMER_CLASS = preload("res://Script/Timer.gd")
const ACTION_CLASS = preload("res://Script/InputAction.gd")
const PROJECTILE = preload("res://Scene/Entities/Arrow.tscn")

enum HorizontalOrientation {Still, Left, Right}
enum VerticalOrientation {Still, Jumping, Falling}
enum ActionOrientation {Nothing, Shooting}

## V
var MAX_HORIZONTAL_SPEED = 300.0 		# Acceleration, pixel per second
var MAX_VERTICAL_DOWN_SPEED = 600.0 	# Pixel per second
var GRAVITY = 128/5 					# Pixel per second
var CONSTANT_HORIZONTAL_FRICTION = 65.0 # Pixel per second
var RUN_ACCELERATION = 72.5 			# Pixel per second
var JUMP_SPEED_INITIAL = 128*1.5
var JUMP_SPEED_VARIADIC = 128/2.5
var MANUAL_DOWN_SPEED = 150.0			# Pixel per second
var DASH_SPEED = 500.0 					# Pixel per second

## Jump
var jumpAction = ACTION_CLASS.new("character_jump")
var jumpCount = 0
var jumpCountMax = 3
var jumpBlockTimer = TIMER_CLASS.new()
var jumpTimerThreshold = 0.25 # How long time it is in seconds between first jump before double jump can be made.
var jumpVariadicPartTimer = TIMER_CLASS.new()
var jumpVariadicPartTimerThreshold = 0.1 # Seconds
var jumpInitialJump = false
var jumpTouchedGroundSinceLastJump = false

## Run 
var accelerationPrevious = Vector2()
var acceleration = Vector2()
var velocity = Vector2()

## Dash
var dashActionLeft = ACTION_CLASS.new("character_dash_left")
var dashActionRight = ACTION_CLASS.new("character_dash_right")
var dashBlockTimer = TIMER_CLASS.new()
var dashBlockTimerThreshold = 0.1
var dashLengthTimer = TIMER_CLASS.new()
var dashLengthThreshold = 0.2
var dashCounter = 0
var dashCounterMax = 2
var dashTouchedGroundSinceLastDash = false

## Shoot
var shootBlockTimer = TIMER_CLASS.new()
var shootBlockTimerThreshold = 0.10
var projectileInitialVelocity = Vector2(-500, -50)

## Various
var frameDelta = 0
var upVector = Vector2(0, -1.0)

## Player orientation
var horizontalOrientation = HorizontalOrientation.Still
var verticalOrientation = VerticalOrientation.Still
var actionOrientation = ActionOrientation.Nothing
var isDashing = false

func _ready():
	pass
	
func preUpdate(delta):
	accelerationPrevious = acceleration
	acceleration = Vector2()
	frameDelta = delta
	jumpAction.updateState()
	dashActionLeft.updateState()
	dashActionRight.updateState()

func computeHorizontalMovement():
	var characterLeft = Input.is_action_pressed("character_left")
	var characterRight = Input.is_action_pressed("character_right")
	if characterLeft == characterRight:
		acceleration.x = 0
	elif characterLeft:
		acceleration.x = -RUN_ACCELERATION
	elif characterRight:
		acceleration.x = RUN_ACCELERATION

	# Orientation
	if velocity.x == 0:
		horizontalOrientation = HorizontalOrientation.Still
	elif velocity.x < 0:
		horizontalOrientation = HorizontalOrientation.Left
	elif velocity.x > 0:
		horizontalOrientation = HorizontalOrientation.Right

func computeVerticalMovement():
	# Jump
	if want_jump() && can_jump():
		do_jump()
	if is_on_floor():
		jumpCount = 0
		dashCounter = 0
		jumpTouchedGroundSinceLastJump = true
		verticalOrientation = VerticalOrientation.Still
	#if verticalOrientation == VerticalOrientation.Jumping && velocity.y > 0:
	#	verticalOrientation = VerticalOrientation.Falling

	# Manual down
	if Input.is_action_pressed("character_down") && !is_on_floor():
		acceleration.y += MANUAL_DOWN_SPEED

func want_jump():
	# This should be incremented each frame, and because this function must be called each frame it is.
	jumpBlockTimer.increase_timer_value(frameDelta)

	# Check if this is the end of the end of the last jump, this is easiest done before the start of next jump.
	# Check release and if there' any idea to even increment it. 
	if jumpAction.isWasPressed() && jumpCount < jumpCountMax: 
		jumpCount += 1
	
	if jumpAction.isJustPressed() || jumpAction.isPressed():
		return true

	# TODO
	jumpVariadicPartTimer.reset()
	return false

func can_jump():
	jumpInitialJump = false

	if (jumpTouchedGroundSinceLastJump ||
		jumpVariadicPartTimer.get_value() < jumpVariadicPartTimerThreshold):
		if jumpAction.isJustPressed() && jumpCount < jumpCountMax:
			jumpInitialJump = true 
			jumpVariadicPartTimer.reset()
			return true
		elif jumpAction.isPressed() && !is_on_floor() && jumpCount < jumpCountMax:
			jumpVariadicPartTimer.increase_timer_value(frameDelta)
			return true
	return false

func do_jump():
	jumpTouchedGroundSinceLastJump = false
	verticalOrientation = VerticalOrientation.Jumping
	
	# Actually, in double jump this will be true for the start of the first jump and the extra jump.
	if jumpInitialJump: 
		velocity.y = min(velocity.y, 0) # Will "reset" downgravity.
		velocity.y = -JUMP_SPEED_INITIAL
	else:
		velocity.y -= JUMP_SPEED_VARIADIC

func computeShoot():
	shootBlockTimer.increase_timer_value(frameDelta)
	if Input.is_action_just_pressed("character_shoot") && shootBlockTimer.get_value() > shootBlockTimerThreshold:
		shootBlockTimer.reset()
		actionOrientation = ActionOrientation.Shooting
		var projectile = PROJECTILE.instance()
		projectile.set_lifetime(2.0)
		projectile.position = position
		if !$AnimatedSprite.flip_h:
			projectile.apply_impulse(Vector2(), projectileInitialVelocity * Vector2(-1, 1))
		else:
			projectile.set_horizontal_flip(true)
			projectile.apply_impulse(Vector2(), projectileInitialVelocity)
		get_tree().get_root().add_child(projectile)
	else:
		actionOrientation = ActionOrientation.Nothing

func computeDash():
	dashBlockTimer.increase_timer_value(frameDelta)
	
	# TODO Set dash state, if dashing then dont apply gravity and dont change speed.
	# Dash length should be variadic depending on length on downpress.
	if dashActionLeft.isJustPressed() && dashBlockTimer.get_value() > dashBlockTimerThreshold && dashCounter < dashCounterMax:
		dashCounter += 1
		isDashing = true
		acceleration.x -= DASH_SPEED
		dashBlockTimer.reset()
		dashLengthTimer.reset()
		velocity = Vector2()
		return
	elif dashActionRight.isJustPressed() && dashBlockTimer.get_value() > dashBlockTimerThreshold  && dashCounter < dashCounterMax:
		dashCounter += 1
		isDashing = true
		acceleration.x = DASH_SPEED
		dashBlockTimer.reset()
		dashLengthTimer.reset()
		velocity = Vector2()
		return

	if dashActionLeft.isPressed() && dashLengthTimer.get_value() < dashLengthThreshold:
	#	acceleration.x -= DASH_SPEED * 0.1
		dashLengthTimer.increase_timer_value(frameDelta)
	elif dashActionRight.isPressed() && dashLengthTimer.get_value() < dashLengthThreshold:
	#	acceleration.x += DASH_SPEED * 0.1
		dashLengthTimer.increase_timer_value(frameDelta)
	else:
		isDashing = false

func computeHorizontalFriction():
	if isDashing:
		return

	if velocity.x < 0:
		acceleration.x += CONSTANT_HORIZONTAL_FRICTION
		# Check if the friction will cause the direction to change on the velocity
		if velocity.x + acceleration.x > 0:
			acceleration.x =  -velocity.x # Essentially set to 0
	elif velocity.x > 0:
		acceleration.x -= CONSTANT_HORIZONTAL_FRICTION
		# Check if the friction will cause the direction to change on the velocity
		if velocity.x + acceleration.x < 0:
			acceleration.x = -velocity.x # Essentially set to 0

func computeVerticalFriction():
	if isDashing:
		return
	acceleration.y += GRAVITY

func clampValues():
	if isDashing:
		return
	velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED) # TODO
	velocity.y = min(velocity.y, MAX_VERTICAL_DOWN_SPEED) # TODO

func setDesiredAnimations():
	if actionOrientation == ActionOrientation.Shooting || ($AnimatedSprite.animation == "shoot" && !$AnimatedSprite.playedAtleastOnce):
		$AnimatedSprite.setDesiredAnimation("shoot")
		return
	#elif verticalOrientation == VerticalOrientation.Jumping:
	#	$AnimatedSprite.setDesiredAnimation("jump")
	#elif verticalOrientation == VerticalOrientation.Falling:
	#	$AnimatedSprite.setDesiredAnimation("falling")
	elif horizontalOrientation != HorizontalOrientation.Still:
		$AnimatedSprite.setDesiredAnimation("run")
	elif horizontalOrientation == HorizontalOrientation.Still:
		$AnimatedSprite.setDesiredAnimation("stand")
		
	if horizontalOrientation == HorizontalOrientation.Left:
		$AnimatedSprite.setDesiredFlipH(true)
	elif horizontalOrientation == HorizontalOrientation.Right:
		$AnimatedSprite.setDesiredFlipH(false)

func _physics_process(delta):
	preUpdate(delta)
	computeHorizontalMovement()
	computeVerticalMovement()
	computeShoot()
	computeDash()
	computeHorizontalFriction()
	computeVerticalFriction()
	clampValues()
	velocity = move_and_slide(velocity + acceleration, upVector) # We don't need to multiply velocity by delta because MoveAndSlide already takes delta time into account.

	setDesiredAnimations()
	$AnimatedSprite.computeAnimationvalue(delta)