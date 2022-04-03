extends Sprite




var dragging = false
var drag_offset = Vector2()
var zoom = 1.0
var can_drag = true

func _ready():
	pass




func input(event):
	if visible:
		if event is InputEventMouseMotion and not dragging:
			drag_offset = (event.position * zoom - position)
		
		if event is InputEventMouseButton:
			if event.is_pressed() and event.button_index == BUTTON_MASK_LEFT:
				dragging = true
				
			if not event.is_pressed() and event.button_index == BUTTON_MASK_LEFT:
				dragging = false
				
		if event is InputEventMouseMotion and dragging:
			position = (event.position * zoom - drag_offset)

func _on_ViewportContainer_zoom_changed(z):
	zoom = z
	pass
