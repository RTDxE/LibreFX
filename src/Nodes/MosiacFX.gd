extends "res://Nodes/effect_node.gd"




var prev_width
var prev_height

func _ready():
	$Viewport / TextureRect.material.set_shader_param("tex_size", global.texture_size)
	$Viewport / TextureRect.material.set_shader_param("width", 2)
	$Viewport / TextureRect.material.set_shader_param("height", 2)
	prev_width = 2
	prev_height = 2
	pass





func _on_WidthValue_value_changed(value):
	global.history.create_action("Width changed")
	global.history.add_do_property($VBoxContainer / HBoxContainer / WidthValue.get_line_edit(), "text", str(value) + " px")
	global.history.add_undo_property($VBoxContainer / HBoxContainer / WidthValue.get_line_edit(), "text", str(prev_width) + " px")
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "width", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "width", prev_width)
	global.history.add_do_property(self, "prev_width", value)
	global.history.add_undo_property(self, "prev_width", prev_width)
	
	if $LockRatio.pressed:
		global.history.add_do_property($VBoxContainer / HBoxContainer2 / HeightValue.get_line_edit(), "text", str(value) + " px")
		global.history.add_undo_property($VBoxContainer / HBoxContainer2 / HeightValue.get_line_edit(), "text", str(prev_width) + " px")
		global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "height", value)
		global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "height", prev_width)
		global.history.add_do_property(self, "prev_height", value)
		global.history.add_undo_property(self, "prev_height", prev_height)
		
		
		
	global.history.commit_action()
	
	pass


func _on_HeightValue_value_changed(value):
	global.history.create_action("Height changed")
	global.history.add_do_property($VBoxContainer / HBoxContainer2 / HeightValue.get_line_edit(), "text", str(value) + " px")
	global.history.add_undo_property($VBoxContainer / HBoxContainer2 / HeightValue.get_line_edit(), "text", str(prev_height) + " px")
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "height", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "height", prev_height)
	
	if $LockRatio.pressed:
		global.history.add_do_property($VBoxContainer / HBoxContainer / WidthValue.get_line_edit(), "text", str(value) + " px")
		global.history.add_undo_property($VBoxContainer / HBoxContainer / WidthValue.get_line_edit(), "text", str(prev_height) + " px")
		global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "width", value)
		global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "width", prev_height)
		prev_width = value
		
		
	global.history.commit_action()
	prev_height = value
	pass

func get_values():
	var dict = {}
	dict["width"] = $Viewport / TextureRect.material.get_shader_param("width")
	dict["height"] = $Viewport / TextureRect.material.get_shader_param("height")
	print(dict["width"], dict["height"])
	dict["ratio_lock"] = $LockRatio.pressed
	return dict
	
func set_values(dict):
	$VBoxContainer / HBoxContainer / WidthValue.value = dict["width"]
	$VBoxContainer / HBoxContainer2 / HeightValue.value = dict["height"]
	$Viewport / TextureRect.material.set_shader_param("width", dict["width"])
	$Viewport / TextureRect.material.set_shader_param("height", dict["height"])
	print(dict["width"], dict["height"])
	$LockRatio.pressed = dict["ratio_lock"]
