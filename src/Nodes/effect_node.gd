extends GraphNode




signal node_closed
var original_title = title
var type = 0
var input_node

func _ready():
	add_color_override("close_color", Color(1, 1, 1, 1))
	$Viewport.size = global.texture_size

	pass





func get_input():
	return input_node

func set_input(node):
	input_node = node
	$Viewport / TextureRect.texture = node.get_output()
	$Viewport / TextureRect.texture.flags = Texture.FLAG_REPEAT

func get_output():
	
	return $Viewport.get_texture()
	
func clear_input():
	input_node = null
	$Viewport / TextureRect.texture = null

	
func _on_Effect_close_request():
	emit_signal("node_closed", self)
	pass
	
func translate_node():
	title = tr(original_title)

func _on_Effect_dragged(from, to):
	global.history.create_action("Node moved")
	global.history.add_do_property(self, "offset", to)
	global.history.add_undo_property(self, "offset", from)
	global.history.commit_action()
	pass
