var timer = 0

func increase_timer_value(value):
	timer += value
	
func reset():
	timer = 0
	
func set_timer_value(value):
	timer = value

func get_value():
	return timer