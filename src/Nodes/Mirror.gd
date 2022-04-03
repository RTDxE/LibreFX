extends "res://Nodes/effect_node.gd"




var prev_x
var prev_y

func _ready():
	prev_x = $VBoxContainer / MirrorX.pressed
	prev_y = $VBoxContainer / MirrorY.pressed
	pass





func _on_MirrorY_toggled(button_pressed):
	global.history.create_action("Mirror Y Toggled")
	global.history.add_do_property($VBoxContainer / MirrorY, "pressed", button_pressed)
	global.history.add_undo_property($VBoxContainer / MirrorY, "pressed", prev_y)
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "mirror_y", button_pressed)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "mirror_y", prev_y)
	global.history.add_do_property(self, "prev_y", button_pressed)
	global.history.add_undo_property(self, "prev_y", prev_y)
	global.history.commit_action()
	pass


func _on_MirrorX_toggled(button_pressed):
	global.history.create_action("Mirror X Toggled")
	global.history.add_do_property($VBoxContainer / MirrorX, "pressed", button_pressed)
	global.history.add_undo_property($VBoxContainer / MirrorX, "pressed", prev_x)
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "mirror_x", button_pressed)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "mirror_x", prev_x)
	global.history.add_do_property(self, "prev_x", button_pressed)
	global.history.add_undo_property(self, "prev_x", prev_x)
	global.history.commit_action()
	pass

func get_values():
	var dict = {}
	dict["mirror_x"] = $VBoxContainer / MirrorX.pressed
	dict["mirror_y"] = $VBoxContainer / MirrorY.pressed
	return dict
	
func set_values(dict):
	$VBoxContainer / MirrorX.pressed = dict["mirror_x"]
	$VBoxContainer / MirrorY.pressed = dict["mirror_y"]
