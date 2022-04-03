extends "res://Nodes/effect_node.gd"




var prev_value

func _ready():
	prev_value = $HBoxContainer / SpinBox.value
	pass






func _on_SpinBox_value_changed(value):
	global.history.create_action("Posterize changed")
	global.history.add_do_property($HBoxContainer / SpinBox.get_line_edit(), "text", str(value))
	global.history.add_undo_property($HBoxContainer / SpinBox.get_line_edit(), "text", str(prev_value))
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "color_count", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "color_count", prev_value)
	global.history.add_do_property(self, "prev_value", value)
	global.history.add_undo_property(self, "prev_value", prev_value)
	global.history.commit_action()
	
	pass

func get_values():
	var dict = {}
	dict["color_count"] = find_node("SpinBox").value
	return dict
	
func set_values(dict):
	find_node("SpinBox").value = dict["color_count"]
	$Viewport / TextureRect.material.set_shader_param("color_count", dict["color_count"])
