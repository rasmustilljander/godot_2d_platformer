var xValueStart = 0
var xValueEnd = 1
var xValueCurrent = 0 # May not need this one.

# Time in seconds
var timeCurrent = 0
var timeTotal = 1

func set_function(function_):
	function = function_
	
func set_xValue_start(value):
	xValueStart = value
	
func set_xValue_end(value):
	xValueEnd = value
	
func reset():
	timer = 0

func increase_timer_value(value):
	timer += value
	
func update(delta):
	timeCurrent += delta
	if timeCurrent > timeTotal: # TODO Convert to max/min 
		timeCurrent = timeTotal

func get_value(delta):
	# NO support for negative numbers atm
	var currentDelta = timeCurrent / timeTotal

func get_value_stateless(x):
	return function(x)