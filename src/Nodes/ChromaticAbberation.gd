extends "res://Nodes/effect_node.gd"




var prev_value

func _ready():
	prev_value = $HBoxContainer / Strength.value
	pass






func _on_SpinBox_value_changed(value):
	global.history.create_action("Value changed")
	global.history.add_do_property($HBoxContainer / Strength.get_line_edit(), "text", str(value) + " %")
	global.history.add_undo_property($HBoxContainer / Strength.get_line_edit(), "text", str(prev_value) + " %")
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "offset", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "offset", prev_value)
	global.history.add_do_method($Viewport / TextureRect2.material, "set_shader_param", "offset", value)
	global.history.add_undo_method($Viewport / TextureRect2.material, "set_shader_param", "offset", prev_value)
	global.history.add_do_method($Viewport / TextureRect3.material, "set_shader_param", "offset", value)
	global.history.add_undo_method($Viewport / TextureRect3.material, "set_shader_param", "offset", prev_value)
	global.history.add_do_property(self, "prev_value", value)
	global.history.add_undo_property(self, "prev_value", prev_value)
	global.history.commit_action()
	
	
	pass

func get_values():
	var dict = {}
	dict["strength"] = find_node("Strength").value
	return dict
	
func set_values(dict):
	find_node("Strength").value = dict["strength"]
	$Viewport / TextureRect.material.set_shader_param("offset", dict["strength"])
	$Viewport / TextureRect2.material.set_shader_param("offset", dict["strength"])
	$Viewport / TextureRect3.material.set_shader_param("offset", dict["strength"])
	
func set_input(node):
	input_node = node
	$Viewport / TextureRect.texture = node.get_output()
	$Viewport / TextureRect.texture.flags = Texture.FLAG_REPEAT
	$Viewport / TextureRect2.texture = node.get_output()
	$Viewport / TextureRect2.texture.flags = Texture.FLAG_REPEAT
	$Viewport / TextureRect3.texture = node.get_output()
	$Viewport / TextureRect3.texture.flags = Texture.FLAG_REPEAT
