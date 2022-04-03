
extends TextureRect




export (NodePath) var viewport_path

func _ready():
	if viewport_path:
		set_render_texture(viewport_path)
		





func set_render_texture(path):
	texture = get_node(path).get_texture()
	viewport_path = path
