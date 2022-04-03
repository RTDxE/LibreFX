tool 
extends Panel




signal value_changing
signal value_changed

export (float) var min_value = 0.0
export (float) var max_value = 100.0
export (float) var value = 0.0 setget set_value, get_value
export (float) var step_value = 1.0
export (float) var cursor_scale = 1.0
var cur_width = 0.0
var dragging = false

func _ready():
	pass




func set_value(v):
	value = v
	update()

func get_value():
	return value

func _gui_input(event):

	if event is InputEventMouseButton:
		var mpos = event.position
		
		match (event.button_index):
			BUTTON_LEFT:
					dragging = true
					value = round(((mpos.x / rect_size.x) * max_value) / step_value) * step_value
					value = clamp(value, min_value, max_value)
					emit_signal("value_changing", value)
					update()
				
		if not event.is_pressed() and dragging and event.button_index == BUTTON_MASK_LEFT:
			dragging = false
			emit_signal("value_changed", value)
			
	if event is InputEventMouseMotion:
		var mpos = event.position
		if dragging:
			value = round(((mpos.x / rect_size.x) * max_value) / step_value) * step_value
			value = clamp(value, min_value, max_value)
			emit_signal("value_changing", value)
			update()
		

func _draw():
	cur_width = ((rect_size.x) / 10.0) * cursor_scale
	draw_rect(Rect2(0, 0, rect_size.x, rect_size.y), Color(0, 0, 0, 0.2))
	draw_rect(Rect2(0, 0, rect_size.x * (value / max_value) - (cur_width / 2.0), rect_size.y), Color(1, 1, 1, 0.1))

	draw_rect(Rect2(rect_size.x * (value / max_value) - (cur_width / 2.0), 0, cur_width, rect_size.y), Color(1, 1, 1, 0.2))
	pass
