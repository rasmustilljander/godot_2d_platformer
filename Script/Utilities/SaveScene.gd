extends Node

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_released("debug_save_scene"):
		print("A")
		var packed_scene = PackedScene.new()
		packed_scene.pack(get_tree().get_current_scene())
		ResourceSaver.save("res://Generated/1.tscn", packed_scene)