extends "res://Nodes/effect_node.gd"




var gradient = Gradient.new()
var grad_tex = GradientTexture.new()

func _ready():
	find_node("GradientEdit").set_gradient(gradient)
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(0, 0, 0, 1))
	grad_tex.gradient = gradient
	$Viewport / TextureRect.material.set_shader_param("grad", grad_tex)
	pass






func _on_GradientEdit_value_changed(grad):
	
	pass
	
func get_values():
	var dict = {}
	dict["grad"] = global.gradient_to_dict(gradient)
	return dict
	
func set_values(dict):
	gradient = global.dict_to_gradient(dict["grad"])
	find_node("GradientEdit").set_gradient(gradient)
	grad_tex.gradient = gradient
	$Viewport / TextureRect.material.set_shader_param("grad", grad_tex)
	


func _on_Presets_pressed():
	$GradientPresetsDiag.popup_centered()
	pass
