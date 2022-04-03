extends MarginContainer




signal value_type_changed
signal value_changed
signal min_value_changed
signal max_value_changed
var popup
var prop_name = ""
var ready = false

var prev_min
var prev_max

func _ready():
	popup = find_node("MenuButton").get_popup()
	popup.connect("index_pressed", self, "set_value_type")
	prev_min = $VBoxContainer / Curve / MarginContainer / HBoxContainer / MinValue.value
	prev_max = $VBoxContainer / Curve / MarginContainer / HBoxContainer / MaxValue.value
	pass





func set_value_type(type):
	match (type):
		0:
			$VBoxContainer / Value.show()
			$VBoxContainer / ValueRange.hide()
			$VBoxContainer / Curve.hide()
		1:
			$VBoxContainer / Value.hide()
			$VBoxContainer / ValueRange.show()
			$VBoxContainer / Curve.hide()
		2:
			$VBoxContainer / Value.hide()
			$VBoxContainer / ValueRange.hide()
			$VBoxContainer / Curve.show()
	if not ready:
		return 
	emit_signal("value_type_changed", prop_name, type, self)
			
func set_name(n):
	prop_name = n
	
func set_tip(tip):
	hint_tooltip = tip

func refresh():
	find_node("CurveEdit").update()

func set_label(text):
	$VBoxContainer / HBoxContainer / PropertyName.text = text
	
func set_use_range(use_range):
	if not use_range:
		
		find_node("MenuButton").hide()

func set_curve(c):
	$VBoxContainer / Curve / CurveEdit.curve = c
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MinValue.get_line_edit().text = str(c.min_value)
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MaxValue.get_line_edit().text = str(c.max_value)

func get_curve():
	var curve = $VBoxContainer / Curve / CurveEdit.curve.duplicate()
	$VBoxContainer / Curve / CurveEdit.curve = curve
	return curve
	
func set_value(v):
	$VBoxContainer / Value / ConstValue.value = v

func set_vector_value(v):
	set_min_value(v.x)
	set_max_value(v.y)
	
func set_min_value(v):
	$VBoxContainer / ValueRange / MinValue.value = v
	
func set_max_value(v):
	$VBoxContainer / ValueRange / MaxValue.value = v
	
func get_value():
	return $VBoxContainer / Value / ConstValue.value

func get_min_value():
	return $VBoxContainer / ValueRange / MinValue.value
	
func get_max_value():
	return $VBoxContainer / ValueRange / MaxValue.value

func set_value_range(a, b):
	$VBoxContainer / Value / ConstValue.min_value = a
	$VBoxContainer / Value / ConstValue.max_value = b
	
	$VBoxContainer / ValueRange / MinValue.min_value = a
	$VBoxContainer / ValueRange / MinValue.max_value = b
	$VBoxContainer / ValueRange / MaxValue.min_value = a
	$VBoxContainer / ValueRange / MaxValue.max_value = b
	
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MinValue.min_value = a
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MinValue.max_value = b
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MaxValue.min_value = a
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MaxValue.max_value = b
	
	
	

func _on_value_changed(value):
	if not ready:
		return 
	emit_signal("value_changed", prop_name, value)
	pass

func _on_min_max_value_changed(value):
	if not ready:
		return 
	emit_signal("value_changed", prop_name, Vector2($VBoxContainer / ValueRange / MinValue.value, $VBoxContainer / ValueRange / MaxValue.value))
	pass

func set_curve_min_max(a, b):
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MinValue.value = a
	$VBoxContainer / Curve / MarginContainer / HBoxContainer / MaxValue.value = b

func _on_MinValue_value_changed(value):
	global.history.create_action("Curve min value changed")
	global.history.add_do_method($VBoxContainer / Curve / CurveEdit, "set_min", value)
	global.history.add_undo_method($VBoxContainer / Curve / CurveEdit, "set_min", prev_min)
	global.history.add_do_property($VBoxContainer / Curve / MarginContainer / HBoxContainer / MinValue.get_line_edit(), "text", str(value))
	global.history.add_undo_property($VBoxContainer / Curve / MarginContainer / HBoxContainer / MinValue.get_line_edit(), "text", str(prev_min))
	global.history.add_do_property(self, "prev_min", value)
	global.history.add_undo_property(self, "prev_min", prev_min)
	global.history.commit_action()
	
	pass


func _on_MaxValue_value_changed(value):
	global.history.create_action("Curve max value changed")
	global.history.add_do_method($VBoxContainer / Curve / CurveEdit, "set_max", value)
	global.history.add_undo_method($VBoxContainer / Curve / CurveEdit, "set_max", prev_max)
	global.history.add_do_property($VBoxContainer / Curve / MarginContainer / HBoxContainer / MaxValue.get_line_edit(), "text", str(value))
	global.history.add_undo_property($VBoxContainer / Curve / MarginContainer / HBoxContainer / MaxValue.get_line_edit(), "text", str(prev_max))
	global.history.add_do_property(self, "prev_max", value)
	global.history.add_undo_property(self, "prev_max", prev_max)
	global.history.commit_action()
	
	pass
