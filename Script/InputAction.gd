var keyId = ""

var justPressed = false
var isPressed = false
var wasPressed = false

func _init(_keyId):
	keyId = _keyId;
	
func updateState():
	justPressed = Input.is_action_just_pressed(keyId)
	isPressed = Input.is_action_pressed(keyId)
	wasPressed = Input.is_action_just_released(keyId)
	
func isJustPressed():
	return justPressed
	
func isPressed():
	return isPressed
	
func isWasPressed():
	return wasPressed
	