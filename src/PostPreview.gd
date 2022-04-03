extends TextureRect




var render_rect = Vector2(256, 256)

var logo = preload("res://logo512.png")
func _ready():
	pass

func _process(delta):
	update()

func _on_OutputNode_input_changed(tex):
	texture = tex
	pass

func _draw():
	draw_texture_rect(global.checker, Rect2(Vector2(0, 0), get_rect().size), true)
	if global.show_bg_color:
		draw_rect(Rect2(0, 0, rect_size.x, rect_size.y), global.bg_color, true)
	if global.show_bg_tex:
		draw_texture_rect(global.bg_tex, global.transformed_bg_rect, false)
	if texture:
		draw_texture(texture, Vector2(0, 0))
	draw_rect(Rect2(Vector2(1, 0), get_rect().size - Vector2(1, 1)), Color(1, 1, 1, 0.5), false)
	
	draw_rect(Rect2((global.texture_size) / 2 - (render_rect / 2), render_rect + Vector2(1, 1)), Color(0, 0, 0, 1), false)
	draw_rect(Rect2((global.texture_size) / 2 - (render_rect / 2), render_rect), Color(1, 1, 1, 1), false)
	if not texture:
		draw_string(global.font, global.texture_size / 2 - global.font.get_string_size("NO INPUT") / 2 + Vector2(0, global.font.get_height()), "NO INPUT")
	
func _on_RenderTab_render_size_updated(value):
	render_rect = value
	update()
	pass
