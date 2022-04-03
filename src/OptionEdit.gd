extends VBoxContainer




signal value_changed
var prop_name = ""
var ready = false

func _ready():
	pass





func set_name(n):
	prop_name = n
	
func set_label(t):
	find_node("Label").text = t
	
func set_tip(tip):
	hint_tooltip = tip
	
func add_item(item):
	find_node("OptionButton").add_item(item)

func select(id):
	find_node("OptionButton").select(id)

func _on_OptionButton_item_selected(ID):
	if not ready:
		return 
	emit_signal("value_changed", prop_name, ID)
	pass
	
func clear_items():
	find_node("OptionButton").clear()
