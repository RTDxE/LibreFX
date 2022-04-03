extends MarginContainer




signal value_changed
var prop_name = ""
var ready = false

func _ready():
	pass




func set_name(n):
	prop_name = n

func set_label(t):
	$GridContainer / HBoxContainer / Label.text = t
	
func set_tip(tip):
	hint_tooltip = tip

	
func set_value(v):
	$GridContainer / HBoxContainer2 / CheckBox.pressed = v


func _on_CheckBox_pressed():
	if not ready:
		return 
	emit_signal("value_changed", prop_name, $GridContainer / HBoxContainer2 / CheckBox.pressed)
	pass
