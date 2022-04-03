tool 
extends Panel




enum T{TANGENT_LEFT, TANGENT_RIGHT}
var world_transform = Transform2D()
var curve = Curve.new()
var width = 256.0
var height = 256.0

var hover_radius = 8.0

var hover_point = - 1
var selected_point = - 1
var selected_tangent = - 1
var dragging = false
var context_click_pos
var context_menu = PopupMenu.new()

var line_color = Color(1, 1, 1, 0.5)
var grid_color_minor = Color(0.3, 0.3, 0.3, 1)
var grid_color_major = Color(0.5, 0.5, 0.5, 1)
var point_color = Color(0.804688, 0.804688, 0.804688)
var point_select_color = Color(0.477081, 1, 0.417969)
var handle_color = Color(1, 0.222656, 0.587036)
var hover_color = Color(1, 1, 1)

var has_undo_data = false
var undo_data

var editing_point = 0
var prev_pos = Vector2()
var prev_pos_set = false
var prev_point = - 1
var prev_left_tang = 0
var prev_right_tang = 0
var prev_tang_set = false
var final_pos = Vector2()
var final_left_tangent = 0
var final_right_tangent = 0

var font = preload("res://Fonts/curve_font.tres")

func _ready():
	context_menu.connect("id_pressed", self, "context_menu_item_selected")
	add_child(context_menu)
	set_clip_contents(true)
	pass





func _gui_input(event):
	if event is InputEventMouseButton:
		var mpos = event.position
		selected_tangent = get_tangent_at(mpos)
		if selected_tangent == - 1:
			set_selected_point(get_point_at(mpos))
		
		match (event.button_index):
			BUTTON_MASK_RIGHT:
				context_click_pos = mpos
				open_context_menu(get_global_transform().xform(mpos))
			
				
			BUTTON_MASK_LEFT:
				dragging = true
			
		if not event.is_pressed() and dragging and event.button_index == BUTTON_MASK_LEFT:
			dragging = false
			if has_undo_data:
				global.history.create_action("Modify Point" if selected_tangent == - 1 else "Modify Tangent")
				global.history.add_do_property(curve, "_data", curve._data)
				global.history.add_undo_property(curve, "_data", undo_data)
				global.history.commit_action()
				has_undo_data = false
				
							
	if event is InputEventMouseMotion:
		var mpos = event.position
		
		if dragging:
			if selected_point != - 1:
				if not has_undo_data:
					undo_data = curve._data
					has_undo_data = true
				
					
					
					
					
					
					
				if selected_tangent == - 1:
					
					
					var point_pos = get_world_pos(mpos)
					point_pos.y = clamp(point_pos.y, curve.min_value, curve.max_value)
					curve.set_point_offset(selected_point, point_pos.x)
					set_hover_point_index(selected_point)
					set_selected_point(selected_point)
					curve.set_point_value(selected_point, point_pos.y)
					update()
					
				else :
					
					var point_pos = curve.get_point_position(selected_point)
					var control_pos = get_world_pos(mpos)
					var dir = (control_pos - point_pos).normalized()
					var tangent
					if abs(dir.x) > 1e-05:
						tangent = dir.y / dir.x
					else :
						tangent = 9999 * (1 if dir.y >= 0 else - 1)
						
					var link = not Input.is_key_pressed(KEY_SHIFT)
					if selected_tangent == 0:
						curve.set_point_left_tangent(selected_point, tangent)
						
						if link and selected_point != curve.get_point_count() - 1 and not curve.get_point_right_mode(selected_point) != Curve.TANGENT_FREE:
							curve.set_point_right_tangent(selected_point, tangent)
					else :
						curve.set_point_right_tangent(selected_point, tangent)
						if link and selected_point != 0 and not curve.get_point_left_mode(selected_point) != Curve.TANGENT_FREE:
							curve.set_point_left_tangent(selected_point, tangent)
					final_left_tangent = curve.get_point_left_tangent(selected_point)
					final_right_tangent = curve.get_point_right_tangent(selected_point)
					update()
		else :
			set_hover_point_index(get_point_at(mpos))
func _draw():
	update_view_transform()
	
	
	var view_size = get_rect().size
	var min_edge = get_world_pos(Vector2(0, view_size.y))
	var max_edge = get_world_pos(Vector2(view_size.x, 0))
	
	draw_line(Vector2(1, 1), Vector2(view_size.x, 1), grid_color_minor)
	draw_line(Vector2(1, view_size.y), Vector2(view_size.x, view_size.y - 1), grid_color_minor)
	draw_line(Vector2(1, 1), Vector2(1, view_size.y), grid_color_minor)
	draw_line(Vector2(view_size.x, 1), Vector2(view_size.x - 1, view_size.y), grid_color_minor)
	
	draw_set_transform_matrix(world_transform)

	draw_line(Vector2(min_edge.x, curve.min_value), Vector2(max_edge.x, curve.min_value), grid_color_major)
	draw_line(Vector2(max_edge.x, curve.max_value), Vector2(min_edge.x, curve.max_value), grid_color_major)
	draw_line(Vector2(0, min_edge.y), Vector2(0, max_edge.y), grid_color_minor)
	draw_line(Vector2(1, max_edge.y), Vector2(1, min_edge.y), grid_color_minor)
	
	var curve_height = curve.max_value - curve.min_value
	var grid_step = Vector2(0.25, 0.5 * curve_height)
	
	var grid_x = 0
	var grid_y = curve.min_value
	while grid_x < 1.0:
		draw_line(Vector2(grid_x, min_edge.y), Vector2(grid_x, max_edge.y), grid_color_minor)
		grid_x += grid_step.x
	while grid_y < curve.max_value:
		draw_line(Vector2(min_edge.x, grid_y), Vector2(max_edge.x, grid_y), grid_color_minor)
		grid_y += grid_step.y
		
	draw_set_transform_matrix(Transform2D())
	
	
	var offset = Vector2(0, 11)
	var text_color = Color(0.75, 0.75, 0.75, 1)
	draw_string(font, get_view_pos(Vector2(0, curve.min_value)) + offset, "0.0", text_color)
	draw_string(font, get_view_pos(Vector2(0.25, curve.min_value)) + offset, "0.25", text_color)
	draw_string(font, get_view_pos(Vector2(0.5, curve.min_value)) + offset, "0.5", text_color)
	draw_string(font, get_view_pos(Vector2(0.75, curve.min_value)) + offset, "0.75", text_color)
	draw_string(font, get_view_pos(Vector2(1, curve.min_value)) + offset, "1.0", text_color)
	
	offset = Vector2( - 20, - 2)
	var mid = 0.5 * (curve.min_value + curve.max_value)
	draw_string(font, get_view_pos(Vector2(0, curve.min_value)) + offset, str(stepify(curve.min_value, 0.01)), text_color)
	draw_string(font, get_view_pos(Vector2(0, mid)) + offset, str(stepify(mid, 0.01)), text_color)
	draw_string(font, get_view_pos(Vector2(0, curve.max_value)) + offset, str(stepify(curve.max_value, 0.01)), text_color)
	
	
	
	if selected_point >= 0:
		var pos = curve.get_point_position(selected_point)
		if selected_point != 0:
			var control_pos = get_tangent_view_pos(selected_point, 0)
			draw_line(get_view_pos(pos), control_pos, handle_color)
			draw_rect(Rect2(control_pos, Vector2(1, 1)).grow(3), handle_color)
			
		if selected_point != curve.get_point_count() - 1:
			var control_pos = get_tangent_view_pos(selected_point, 1)
			draw_line(get_view_pos(pos), control_pos, handle_color)
			draw_rect(Rect2(control_pos, Vector2(1, 1)).grow(3), handle_color)
			
	
	
	var steps = 100.0
	for i in range(1, steps + 1):
		var p1 = get_view_pos(Vector2((i - 1) / steps, curve.interpolate((i - 1) / steps)))
		var p2 = get_view_pos(Vector2((i) / steps, curve.interpolate((i) / steps)))
		
		
		draw_line(p1, p2, line_color)
	
	
	for p in range(0, curve.get_point_count()):
		var pos = curve.get_point_position(p)
		draw_rect(Rect2(get_view_pos(pos), Vector2(1, 1)).grow(3), point_select_color if p == selected_point else point_color)
	
	
	
	if hover_point > - 1:
		var pos = curve.get_point_position(hover_point)
		draw_rect(Rect2(get_view_pos(pos), Vector2(1, 1)).grow(3), hover_color)
	
func get_point_at(pos):
	for i in range(0, curve.get_point_count()):
		var p = get_view_pos(curve.get_point_position(i))
		if p.distance_to(pos) < hover_radius:
			return i
	return - 1
	
func get_tangent_at(pos):
	if selected_point < 0:
		return - 1
	if selected_point > - 1:
		var control_pos = get_tangent_view_pos(selected_point, 0)
		if control_pos.distance_to(pos) < 8:
			return 0
	if selected_point != curve.get_point_count() - 1:
		var control_pos = get_tangent_view_pos(selected_point, 1)
		if control_pos.distance_to(pos) < 8:
			return 1
	return - 1
	
func set_selected_point(index):
	if selected_point != index:
		selected_point = index
		update()
		
func set_hover_point_index(index):
	if hover_point != index:
		hover_point = index
		update()

func get_view_pos(pos):
	return world_transform.xform(pos)
	
func get_world_pos(pos):
	return world_transform.affine_inverse().xform(pos)


func stroke_rect(rect, col):
	var a = rect.position
	var b = Vector2(rect.position.x + rect.size.x, rect.position.y)
	var c = Vector2(rect.position.x, rect.position.y + rect.size.y)
	var d = rect.position + rect.size

	draw_line(a, b, col)
	draw_line(b, d, col)
	draw_line(d, c, col)
	draw_line(c, a, col)
	
func get_tangent_view_pos(i, tangent):
	var dir = Vector2()
	if tangent == 0:
		dir = - Vector2(1, curve.get_point_left_tangent(i))
	elif tangent == 1:
		dir = Vector2(1, curve.get_point_right_tangent(i))
	var point_pos = get_view_pos(curve.get_point_position(i))
	var control_pos = get_view_pos(curve.get_point_position(i) + dir)
	return point_pos + 32 * (control_pos - point_pos).normalized()

func update_view_transform():
	var control_size = get_size()
	var margin = 24
	var min_y = 0.0
	var max_y = 1.0
	
	min_y = curve.min_value
	max_y = curve.max_value
	
	var world_rect = Rect2(0, min_y, 1, max_y - min_y)
	var wm = Vector2(margin, margin) / control_size
	wm.y *= (max_y - min_y)
	world_rect.position -= wm
	world_rect.size += 2.0 * wm
	
	world_transform = Transform2D()
	world_transform = world_transform.translated( - world_rect.position - Vector2(0, world_rect.size.y))
	world_transform = world_transform.scaled(Vector2(control_size.x, - control_size.y) / world_rect.size)

func remove_point(index):
	var point = {"pos":curve.get_point_position(index), 
			"left_tang":curve.get_point_left_tangent(index), 
			"left_mode":curve.get_point_left_mode(index), 
			"right_tang":curve.get_point_right_mode(index), 
			"right_mode":curve.get_point_right_mode(index)}
	global.history.create_action("Remove curve point")
	global.history.add_do_method(curve, "remove_point", index)
	global.history.add_undo_method(curve, "add_point", point["pos"], point["left_tang"], point["right_tang"], point["left_mode"], point["right_mode"])
	global.history.commit_action()
	if index == selected_point:
		set_selected_point( - 1)
	update()

func add_point(pos):
	var w_pos = get_world_pos(pos)
	w_pos.y = clamp(w_pos.y, 0, 1)
	var i = curve.add_point(w_pos)
	curve.remove_point(i)
	global.history.create_action("Add curve point")
	global.history.add_do_method(curve, "add_point", w_pos)
	global.history.add_undo_method(curve, "remove_point", i)
	global.history.commit_action()
	update()
	
func toggle_linear(t):
	if t == - 1:
		t = selected_tangent
	if t == 0:
		var is_linear = curve.get_point_left_mode(selected_point) == Curve.TANGENT_LINEAR
		var mode = Curve.TANGENT_FREE if is_linear else Curve.TANGENT_LINEAR
		curve.set_point_left_mode(selected_point, mode)
	else :
		var is_linear = curve.get_point_right_mode(selected_point) == Curve.TANGENT_LINEAR
		var mode = Curve.TANGENT_FREE if is_linear else Curve.TANGENT_LINEAR
		curve.set_point_right_mode(selected_point, mode)
	update()
	
func set_both_linear():
	curve.set_point_left_mode(selected_point, Curve.TANGENT_LINEAR)
	curve.set_point_right_mode(selected_point, Curve.TANGENT_LINEAR)
	update()

func open_context_menu(pos):
	context_menu.rect_position = pos

	context_menu.clear()

	if (curve):
		context_menu.add_item("Add point", 0)

		if (selected_point >= 0):
			context_menu.add_item("Remove point", 1)

			if (selected_tangent != - 1):
				context_menu.add_separator()

				context_menu.add_check_item("Linear", 2)

				var is_linear = curve.get_point_left_mode(selected_point == Curve.TANGENT_LINEAR) if selected_tangent == 0 else curve.get_point_right_mode(selected_point) == Curve.TANGENT_LINEAR
										
				context_menu.set_item_checked(context_menu.get_item_index(2), is_linear)

			else :
				if (selected_point > 0 or selected_point + 1 < curve.get_point_count()):
					context_menu.add_separator()

				if (selected_point > 0):
					context_menu.add_check_item("Left linear", 3)
					context_menu.set_item_checked(context_menu.get_item_index(3), 
							curve.get_point_left_mode(selected_point) == Curve.TANGENT_LINEAR)
				if (selected_point + 1 < curve.get_point_count()):
					context_menu.add_check_item("Right linear", 4)
					context_menu.set_item_checked(context_menu.get_item_index(4), 
							curve.get_point_right_mode(selected_point) == Curve.TANGENT_LINEAR)
				if (selected_point > 0 and selected_point + 1 < curve.get_point_count()):
					context_menu.add_check_item("Both linear", 5)
					context_menu.set_item_checked(context_menu.get_item_index(5), (curve.get_point_left_mode(selected_point) == Curve.TANGENT_LINEAR and curve.get_point_right_mode(selected_point) == Curve.TANGENT_LINEAR))
		
		context_menu.add_separator("")
		context_menu.add_item("Reset Curve", 6)
	context_menu.set_size(Vector2(0, 0))
	context_menu.popup()
	pass
	
func context_menu_item_selected(id):
	match (id):
		0:
			add_point(context_click_pos)
		1:
			remove_point(selected_point)
		2:
			toggle_linear( - 1)
		3:
			toggle_linear(0)
		4:
			toggle_linear(1)
		5:
			set_both_linear()
		6:
			reset_curve()
		

func reset_curve():
	if (curve):
		curve.clear_points()
		curve.add_point(Vector2(0, lerp(curve.min_value, curve.max_value, 0.5)))
		curve.add_point(Vector2(1, lerp(curve.min_value, curve.max_value, 0.5)))
		update()

func set_min(low):
	curve.min_value = low
	clamp_points()
	update()

func set_max(high):
	curve.max_value = high
	clamp_points()
	update()
	
func clamp_points():
	for i in range(0, curve.get_point_count()):
		curve.set_point_value(i, clamp(curve.get_point_position(i).y, curve.min_value, curve.max_value))
