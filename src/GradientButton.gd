extends Button




var texture

func _ready():
	pass




func _draw():
	draw_texture_rect(texture, Rect2(0, 0, get_rect().size.x, get_rect().size.y), false)
