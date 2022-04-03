extends GraphNode




export (NodePath) var source_path
var texture
var original_title = title

func _ready():
	if source_path:
		
		texture = get_node(source_path).get_texture()
	
	
	pass





func get_output():
	return texture
	
	
func translate_node():
	title = tr(original_title)
