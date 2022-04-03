extends ColorRect




signal color_change
signal remove_me

var prev_color = Color(1, 1, 1, 1)

func _ready():
	pass






func _on_ColorRect_gui_input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_MASK_LEFT:
			emit_signal("color_change", self, color, get_index())
		elif ev.button_index == BUTTON_MASK_RIGHT:
			emit_signal("color_change", null, color, get_index())
			emit_signal("remove_me", self)
	pass

func _draw():
	draw_texture_rect(global.checker8, Rect2(Vector2(0, 0), get_rect().size), true)
	draw_rect(Rect2(Vector2(0, 0), get_rect().size), color, true)
	draw_rect(Rect2(Vector2(0, 0), get_rect().size), Color(1, 1, 1, 1), false)
