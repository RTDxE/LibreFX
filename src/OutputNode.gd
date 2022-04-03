extends GraphNode




signal input_changed
var texture
var original_title = title
var input_node

func _ready():
	pass




func set_input(node):
	input_node = node
	texture = node.get_output()
	emit_signal("input_changed", texture)
	
func clear_input():
	input_node = null
	texture = null
	emit_signal("input_changed", texture)

func translate_node():
	title = tr(original_title)

func get_input():
	return input_node
