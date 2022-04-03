extends TextureRect




signal pivot_changed
var pivot = Vector2(0, 0)
var last_pivot = pivot
var dragging = false
var pos = Vector2()


func _ready():
	pass





func _gui_input(event):
	if event is InputEventMouseMotion:
		pos = event.position
	if event is InputEventMouseButton and event.button_index == BUTTON_MASK_LEFT and event.is_pressed():
		dragging = true
		
	if dragging:
		var w = texture.get_width()
		var h = texture.get_height()
		pivot = Vector2(clamp((pos.x - w / 2.0) / w, - 0.5, 0.5), clamp((pos.y - h / 2.0) / h, - 0.5, 0.5)) * 2.0
		
		update()
	
	if event is InputEventMouseButton and not event.is_pressed():
		dragging = false
		emit_signal("pivot_changed", pivot)
		
		
		
		
		
		
		
		
		
		
		


func _draw():
	var w = texture.get_width()
	var h = texture.get_height()
	var draw_point = Vector2(w / 2.0, h / 2.0) + (pivot * Vector2(w, h)) / 2.0
	draw_line(Vector2(draw_point.x + 1, 0), Vector2(draw_point.x + 1, h), Color(0, 0, 0, 0.3))
	draw_line(Vector2(0, draw_point.y + 1), Vector2(w, draw_point.y + 1), Color(0, 0, 0, 0.3))
	draw_line(Vector2(draw_point.x, 0), Vector2(draw_point.x, h), Color(1, 1, 1, 0.75))
	draw_line(Vector2(0, draw_point.y), Vector2(w, draw_point.y), Color(1, 1, 1, 0.75))
	
	
	

func _on_Reset_pressed():
	pivot = Vector2(0, 0)
	emit_signal("pivot_changed", pivot)
	update()
	pass
