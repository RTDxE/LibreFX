extends VBoxContainer




signal value_changed
signal value_type_changed
var popup
var prop_name = ""
var ready = false

func _ready():
	popup = find_node("MenuButton").get_popup()
	popup.connect("index_pressed", self, "set_value_type")
	pass





func set_use_range(use_range):
	if not use_range:
		find_node("MenuButton").hide()
	else :
		find_node("MenuButton").show()

func set_name(n):
	prop_name = n

func set_label(text):
	find_node("Name").text = text
	
func set_tip(tip):
	$MarginContainer.hint_tooltip = tip
	
func _on_value_changed(value):
	if not ready:
		return 
	emit_signal("value_changed", prop_name, Vector2(find_node("XValue").value, find_node("YValue").value))
	pass

func set_x_value(value):
	find_node("XValue").value = value
	
func set_y_value(value):
	find_node("YValue").value = value
	
func set_vector(value):
	find_node("XValue").value = value.x
	find_node("YValue").value = value.y
	
func set_rect(value):
	find_node("XValueMin").value = value.position.x
	find_node("YValueMin").value = value.position.y
	find_node("XValueMax").value = value.size.x
	find_node("YValueMax").value = value.size.y
	
func set_min_value(value):
	find_node("XValue").min_value = value
	find_node("YValue").min_value = value
	find_node("XValueMin").min_value = value
	find_node("YValueMin").min_value = value
	find_node("XValueMax").min_value = value
	find_node("YValueMax").min_value = value
	

func set_max_value(value):
	find_node("XValue").max_value = value
	find_node("YValue").max_value = value
	find_node("XValueMin").max_value = value
	find_node("YValueMin").max_value = value
	find_node("XValueMax").max_value = value
	find_node("YValueMax").max_value = value
	
	
func get_vector():
	return Vector2(find_node("XValue").value, find_node("YValue").value)
	
func get_range():
	return Rect2(find_node("XValueMin").value, find_node("YValueMin").value, find_node("XValueMax").value, find_node("YValueMax").value)
	
func _on_range_value_changed(value):
	if not ready:
		return 
	emit_signal("value_changed", prop_name, get_range())
	pass



func set_value_type(type):
	match (type):
		0:
			find_node("Vector").show()
			find_node("VectorRange").hide()
		1:
			find_node("Vector").hide()
			find_node("VectorRange").show()
	emit_signal("value_type_changed", prop_name, type, self)
