tool 
extends Panel



signal value_changed

var world_transform = Transform2D()
var arrow = preload("res://dropdown_arrow.png")
var colour_picker
var texture
var gradient_tex = GradientTexture.new()
var gradient
var selected_point = - 1
var last_point = - 1
var last_color = Color(1, 1, 1, 1)
var dragging = false
var width = 1
var height = 1
var point_rect

var wait = 0

var has_undo_data = false
var undo_offsets
var undo_colors

export (bool) var allow_alpha = true



func _ready():
	
	
	
	
	pass



func _gui_input(event):
	var mpos = Vector2()
	if event is InputEventMouseMotion:
		mpos = event.position
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_MASK_LEFT:
			if selected_point < 0:
				selected_point = get_point_at(event.position)
				if selected_point > - 1:
					last_point = selected_point
					last_color = gradient.get_color(selected_point)
			dragging = true
			
		if event.button_index == BUTTON_MASK_RIGHT:
			var point = get_point_at(event.position)
			if point > - 1 and gradient.get_point_count() > 2:
				if not has_undo_data:
					has_undo_data = true
					undo_offsets = gradient.offsets
					undo_colors = gradient.colors
				gradient.remove_point(point)
				
				update()
			
		if event.button_index == BUTTON_MASK_LEFT and event.doubleclick:
			if selected_point < 0:
				if not has_undo_data:
					has_undo_data = true
					undo_offsets = gradient.offsets
					undo_colors = gradient.colors
				gradient.add_point(event.position.x / width, last_color)
				ColourSelector.get_node("ColorSelector/ColorPicker").edit_alpha = allow_alpha
				
				ColourSelector.get_node("ColorSelector/ColorPicker").connect("color_changed", self, "set_colour")
				ColourSelector.get_node("ColorSelector").popup_centered()
				ColourSelector.get_node("ColorSelector/ColorPicker").color = last_color
				
				update()
			else :
				if not has_undo_data:
					has_undo_data = true
					undo_offsets = gradient.offsets
					undo_colors = gradient.colors
				ColourSelector.get_node("ColorSelector/ColorPicker").edit_alpha = allow_alpha
				
				ColourSelector.get_node("ColorSelector/ColorPicker").connect("color_changed", self, "set_colour")
				ColourSelector.get_node("ColorSelector").popup_centered()
				ColourSelector.get_node("ColorSelector/ColorPicker").color = gradient.get_color(last_point)
				update()
			
		if event.button_index == BUTTON_MASK_LEFT and not event.is_pressed():
			dragging = false
			selected_point = - 1
			if has_undo_data:
				print("undo set")
				global.history.create_action("Gradient Changed")
				global.history.add_do_method(gradient, "set_offsets", gradient.offsets)
				global.history.add_do_method(gradient, "set_colors", gradient.colors)
				global.history.add_undo_method(gradient, "set_offsets", undo_offsets)
				global.history.add_undo_method(gradient, "set_colors", undo_colors)
				global.history.add_do_method(self, "update")
				global.history.add_undo_method(self, "update")
				global.history.commit_action()
				has_undo_data = false

	if event is InputEventMouseMotion:
		var pos = event.position.x / width
		pos = clamp(pos, 0, 1)
		if dragging and selected_point > - 1:
			if not has_undo_data:
				has_undo_data = true
				undo_offsets = gradient.offsets
				undo_colors = gradient.colors
			gradient.set_offset(selected_point, pos)
			
			var offset = 0.0
			if selected_point > 0:
				offset = gradient.get_offset(selected_point - 1)
				if offset == pos:
					selected_point -= 1
			if selected_point < gradient.get_point_count():
				offset = gradient.get_offset(selected_point + 1)
				if offset == pos:
					selected_point += 1

			
			update()

func _draw():
	if not gradient:
		return 
	
	
	width = get_rect().size.x
	height = get_rect().size.y
	draw_texture_rect(global.checker, Rect2(0, 0, get_rect().size.x, get_rect().size.y), true)
	draw_texture_rect(texture, Rect2(0, 0, get_rect().size.x, get_rect().size.y), false)

	for i in gradient.get_point_count():
		
		draw_rect(Rect2(Vector2(gradient.get_offset(i) * width - 5 + 1, 0 + 1), Vector2(10, height - 1)), Color(0, 0, 0, 1), false)
		draw_rect(Rect2(Vector2(gradient.get_offset(i) * width - 5, 0), Vector2(10, height - 1)), Color(1, 1, 1, 1), false)
		

func set_colour(c):
	if last_point > - 1:
		print("undo color")
		global.history.create_action("Set Gradient Color")
		global.history.add_do_method(gradient, "set_color", last_point, c)
		global.history.add_undo_method(gradient, "set_color", last_point, last_color)
		global.history.add_do_property(self, "last_color", c)
		global.history.add_undo_property(self, "last_color", last_color)
		global.history.add_do_method(self, "update")
		global.history.add_undo_method(self, "update")
		global.history.commit_action()
		
		
		

func get_point_at(pos):
	for i in gradient.get_point_count():
		var rect = Rect2(Vector2(gradient.get_offset(i) * width - 4, 0), Vector2(11, height - 1))
		if rect.has_point(pos):
			return i
	return - 1

		
static func sort(a, b):
	if a[0] < b[0]:
		return true
		
func set_gradient(g):
	gradient = g
	gradient_tex.gradient = gradient
	texture = gradient_tex
