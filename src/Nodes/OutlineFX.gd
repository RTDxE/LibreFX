extends "res://Nodes/effect_node.gd"




var color_picker

var prev_inner
var prev_outer
var prev_color

func _ready():
	color_picker = ColourSelector.get_node("ColorSelector/ColorPicker")
	prev_color = Color(1, 1, 1, 1)
	pass








func _on_OuterThresh_value_changed(value):
	global.history.create_action("Outer threshold changed")
	global.history.add_do_property($MarginContainer / VBoxContainer / HBoxContainer2 / OuterThresh, "value", value)
	global.history.add_undo_property($MarginContainer / VBoxContainer / HBoxContainer2 / OuterThresh, "value", prev_outer)
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "outer", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "outer", prev_outer)
	global.history.add_do_property(self, "prev_outer", value)
	global.history.add_undo_property(self, "prev_outer", prev_outer)
	global.history.commit_action()
	
	pass


func _on_InnerThresh_value_changed(value):
	global.history.create_action("Inner threshold changed")
	global.history.add_do_property($MarginContainer / VBoxContainer / HBoxContainer / InnerThresh, "value", value)
	global.history.add_undo_property($MarginContainer / VBoxContainer / HBoxContainer / InnerThresh, "value", prev_inner)
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "inner", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "inner", prev_inner)
	global.history.add_do_property(self, "prev_inner", value)
	global.history.add_undo_property(self, "prev_inner", prev_inner)
	global.history.commit_action()
	
	pass

func get_values():
	var dict = {}
	dict["inner"] = find_node("InnerThresh").value
	dict["outer"] = find_node("OuterThresh").value
	dict["color"] = global.color_to_dict(find_node("ColorRect").color)
	return dict
	
func set_values(dict):
	find_node("InnerThresh").value = dict["inner"]
	find_node("OuterThresh").value = dict["outer"]
	var col = global.dict_to_color(dict["color"])
	find_node("ColorRect").color = col
	$Viewport / TextureRect.material.set_shader_param("inner", dict["inner"])
	$Viewport / TextureRect.material.set_shader_param("outer", dict["outer"])
	$Viewport / TextureRect.material.set_shader_param("outline_col", col)

func _on_ColorRect_color_change(item, col, index):
	
	color_picker.connect("color_changed", self, "_on_ColorPicker_color_picked")
	color_picker.color = col
	ColourSelector.get_node("ColorSelector").popup(Rect2(item.get_global_position() + Vector2(24, 0), Vector2(306, 466)))
	pass

func _on_ColorPicker_color_changed(color):
	$MarginContainer / VBoxContainer / MarginContainer / ColorRect.color = color
	$Viewport / TextureRect.material.set_shader_param("outline_col", color)
	
func _on_ColorPicker_color_picked(color):
	global.history.create_action("Outline color changed")
	global.history.add_do_property($MarginContainer / VBoxContainer / MarginContainer / ColorRect, "color", color)
	global.history.add_undo_property($MarginContainer / VBoxContainer / MarginContainer / ColorRect, "color", prev_color)
	global.history.add_do_property(self, "prev_color", color)
	global.history.add_undo_property(self, "prev_color", prev_color)
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "outline_col", color)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "outline_col", prev_color)
	global.history.commit_action()
	
	
	

func _on_InnerThresh_value_changing(value):
	$Viewport / TextureRect.material.set_shader_param("inner", value)
	pass


func _on_OuterThresh_value_changing(value):
	$Viewport / TextureRect.material.set_shader_param("outer", value)
	pass
