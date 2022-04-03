extends MarginContainer




signal value_changed
var prop_name = ""

func _ready():
	pass




func set_name(n):
	prop_name = n

func set_label(text):
	$GridContainer / Label.text = text
	
func set_tip(tip):
	hint_tooltip = tip

func set_gradient(g):
	find_node("GradientEdit").set_gradient(g)

func _on_GradientEdit_value_changed(value):
	emit_signal("value_changed", prop_name, value)
	pass



func _on_Button_pressed():
	$GradientPresetsDiag.popup_centered()
	pass
