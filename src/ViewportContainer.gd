extends ViewportContainer




signal emitter_changed
signal zoom_changed
signal pan_changed
signal pan_finished
signal reset_camera
signal bg_can_drag
var current_emitter
var dragging = false
var drag_offset = Vector2()
var render_rect = Vector2(256, 256)

var zoom = 1.0
var pan = Vector2()
var prev_cam_offset = Vector2()
var cam_offset = Vector2()
var panning = false
var under_mouse = []

var bg_dragging = false
var bg_drag_offset = Vector2()


export (NodePath) var bg_diag_path
var BgImageDialog
var locked_icon = preload("res://locked.png")

var prev_pos = Vector2()

var color_picker

func _ready():
	color_picker = ColourSelector.get_node("ColorSelector/ColorPicker")
	BgImageDialog = get_node(bg_diag_path)
	if BgImageDialog == null:
		assert ("Invalid BG Image Dialog node path!")
	BgImageDialog.filters = ["*.png"]
	pass


func _process(delta):
	
	if Input.is_action_just_pressed("zoom_in"):
		zoom -= 0.1 * zoom
		zoom = clamp(zoom, 0.01, 100.0)
		if zoom > 0.95 and zoom < 1.05:
			zoom = 1.0
		emit_signal("zoom_changed", zoom)
		
	if Input.is_action_just_pressed("zoom_out"):
		zoom += 0.1 * zoom
		zoom = clamp(zoom, 0.01, 100.0)
		if zoom > 0.95 and zoom < 1.05:
			zoom = 1.0
		emit_signal("zoom_changed", zoom)
		
	update()

func _gui_input(event):
	if current_emitter == null:
		return
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
		
	if Input.is_action_just_pressed("zoom_in"):
		zoom += 0.1 * zoom
		zoom = clamp(zoom, 0.01, 100.0)
		if zoom > 0.95 and zoom < 1.05:
			zoom = 1.0
		emit_signal("zoom_changed", zoom)
		
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			zoom -= 0.1 * zoom
			zoom = clamp(zoom, 0.01, 100.0)
			if zoom > 0.95 and zoom < 1.05:
				zoom = 1.0
			emit_signal("zoom_changed", zoom)
			
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			zoom += 0.1 * zoom
			zoom = clamp(zoom, 0.01, 100.0)
			if zoom > 0.95 and zoom < 1.05:
				zoom = 1.0
			emit_signal("zoom_changed", zoom)
			
		if event.button_index == BUTTON_MASK_RIGHT and not panning:
			pan = event.position
			panning = true
			
		if not event.is_pressed() and panning and event.button_index == BUTTON_MASK_RIGHT:
			panning = false
			prev_cam_offset = cam_offset
			emit_signal("pan_finished")
		
	if not dragging and not bg_dragging:
		under_mouse = []
		for i in global.emitters:
			var ref = i.get_ref()
			if ref:
				var emitter_rect = Rect2(global.texture_size / 2 + ((ref.position - cam_offset) / zoom), Vector2(1, 1)).grow(16 / zoom)
				if event is InputEventMouseButton:
					if emitter_rect.has_point(event.position) and not ref.locked:
						under_mouse.push_back(i)
				
	var selected
	for i in under_mouse:
		var ref = i.get_ref()
		if ref:
			if ref == emitter:
				selected = i
				break
			else :
				selected = i
				
	if under_mouse.size() > 0:
		
		var ref = selected.get_ref()
		if ref:
			var emitter_rect = Rect2(global.texture_size / 2 + ((ref.position - cam_offset) / zoom), Vector2(1, 1)).grow(16 / zoom)
			
			if event is InputEventMouseButton:
				if emitter_rect.has_point(event.position) and not dragging and not bg_dragging:
					if event.is_pressed() and event.button_index == BUTTON_MASK_LEFT:
						dragging = true
						ref.dragging = true
						drag_offset = ((global.texture_size / 2 + ((ref.position - cam_offset) / zoom)) - event.position)
						emit_signal("emitter_changed", selected)
					
				if not event.is_pressed() and event.button_index == BUTTON_MASK_LEFT and not bg_dragging:
					global.history.create_action("Emitter moved")
					global.history.add_do_property(ref, "position", ((((event.position + cam_offset / zoom) - global.texture_size / 2) + drag_offset) * zoom))
					global.history.add_undo_property(ref, "position", prev_pos)
					global.history.add_do_property(ref, "orig_pos", ((((event.position + cam_offset / zoom) - global.texture_size / 2) + drag_offset) * zoom))
					global.history.add_undo_property(ref, "orig_pos", prev_pos)
					global.history.add_do_property(self, "prev_pos", ref.position)
					global.history.add_undo_property(self, "prev_pos", prev_pos)
					global.history.add_do_method(self, "update")
					global.history.add_undo_method(self, "update")
					global.history.commit_action()
					
					dragging = false
					ref.dragging = false
					emit_signal("emitter_changed", selected)
									
			if event is InputEventMouseMotion:
				
				if dragging and ref.dragging and not bg_dragging:
					ref.position = ((((event.position + cam_offset / zoom) - global.texture_size / 2) + drag_offset) * zoom)
					ref.orig_pos = ref.position
					update()
	else :
		
		if event is InputEventMouseButton:
			if event.is_pressed() and event.button_index == BUTTON_MASK_LEFT:
				bg_dragging = true
				bg_drag_offset = ((global.texture_size / 2 + ((global.bg_pos - cam_offset) / zoom)) - event.position)
			if not event.is_pressed() and event.button_index == BUTTON_MASK_LEFT and bg_dragging:
				bg_dragging = false
		if event is InputEventMouseMotion:
			if bg_dragging:
				global.bg_pos = ((((event.position + cam_offset / zoom) - global.texture_size / 2) + bg_drag_offset) * zoom)
		
	
	if event is InputEventMouseMotion:
		if panning:
			emit_signal("pan_changed", (pan - event.position) * zoom)
			cam_offset = prev_cam_offset + (pan - event.position) * zoom

func _on_Particle_Editor_emitter_changed(emitter):
	current_emitter = emitter
	update()
	pass

func _draw():
	
	draw_texture_rect(global.checker, Rect2(Vector2(0, 0), get_rect().size), true)
	if global.show_bg_color:
		draw_rect(Rect2(0, 0, rect_size.x, rect_size.y), global.bg_color, true)
	if global.show_bg_tex:
		var bg_rect = global.bg_tex.get_size()
		global.transformed_bg_rect = Rect2(xform(global.bg_pos - (bg_rect / 2.0)), bg_rect / zoom)
		draw_texture_rect(global.bg_tex, global.transformed_bg_rect, false)

	draw_rect(Rect2(Vector2(1, 0), get_rect().size - Vector2(1, 1)), Color(1, 1, 1, 0.5), false)
	
	draw_rect(Rect2((global.texture_size) / 2 - (render_rect / 2), render_rect + Vector2(1, 1)), Color(0, 0, 0, 1), false)
	draw_rect(Rect2((global.texture_size) / 2 - (render_rect / 2), render_rect), Color(1, 1, 1, 1), false)
	draw_string(global.font, global.texture_size / 2 + Vector2( - global.font.get_string_size(tr("KEY_RENDER_FRAME_LABEL")).x / 2, render_rect.y / 2 + 12), tr("KEY_RENDER_FRAME_LABEL"))
	
	if not current_emitter:
		return 
	var emitter = current_emitter.get_ref()
	
	if emitter:

		if emitter.emitter_shape == 1:
			draw_circle(xform(emitter.position), emitter.get_value(emitter.emitter_min_radius) / zoom, Color(1, 0, 0.5, 0.2))
			draw_circle(xform(emitter.position), emitter.get_value(emitter.emitter_max_radius) / zoom, Color(0, 1, 0.5, 0.2))
		elif emitter.emitter_shape == 2:
			var w = emitter.get_value(emitter.emitter_width)
			var h = emitter.get_value(emitter.emitter_height)
			draw_rect(Rect2(xform(emitter.position) - Vector2(w, h) / zoom, Vector2(w * 2, h * 2) / zoom), Color(0, 1, 0.5, 0.2))
		
	
	
	draw_texture($Viewport.get_texture(), Vector2(0, 0))
	
	for i in global.emitters:
		var ref = i.get_ref()
		if ref:
			draw_rect(Rect2(xform(ref.position) + Vector2(1, 1), Vector2(1, 1)).grow(16 / zoom), Color(0, 0, 0, 0.5), false)
			draw_rect(Rect2(xform(ref.position), Vector2(1, 1)).grow(16 / zoom), Color(1, 1, 1, 0.5), false)
			if ref.locked:
				draw_texture(locked_icon, xform(ref.position) - Vector2(4, 5), Color(0, 0, 0, 1))
				draw_texture(locked_icon, xform(ref.position) - Vector2(5, 6))
	
	if emitter:
		
		draw_line(xform(emitter.position), xform(emitter.position) + Vector2(0, 64 / zoom).rotated(emitter.rotation), Color(1, 1, 1, 1))
		
		var nb_points = 32
		var points_arc = PoolVector2Array()
		var center = xform(emitter.position)
		points_arc.push_back(center)
		var colors = PoolColorArray([Color(1, 1, 1, 0.3)])
		var spread = clamp(emitter.get_value(emitter.p_spread), 0, 180.0)
		var angle_from = emitter.rotation_degrees - spread
		var angle_to = emitter.rotation_degrees + spread
		for i in range(nb_points + 1):
			var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points + 90)
			points_arc.push_back(center + Vector2(1, 0).rotated(angle_point) * 64 / zoom)
		draw_polygon(points_arc, colors)
		
		
		
		draw_rect(Rect2(xform(emitter.position) + Vector2(1, 1), Vector2(1, 1)).grow(16 / zoom), Color(0, 0, 0, 1), false)
		draw_rect(Rect2((global.texture_size / 2 + (emitter.position - cam_offset) / zoom), Vector2(1, 1)).grow(16 / zoom), Color(1, 1, 1, 1), false)
		var display_text = emitter.emitter_name + (" (hidden)" if not emitter.visibility else "")
		draw_string(global.font, xform(emitter.position) - Vector2(global.font.get_string_size(display_text).x / 2, 18 / zoom) + Vector2(1, 1), display_text, Color(0, 0, 0, 1))
		draw_string(global.font, xform(emitter.position) - Vector2(global.font.get_string_size(display_text).x / 2, 18 / zoom), display_text)
		
			
	
	draw_string(global.font, Vector2(16, global.texture_size.y - 16), "Zoom: " + str(round(pow(round(zoom * 100.0) / 100.0, - 1.0) * 100.0)))
	draw_string(global.font, Vector2(8, 16), tr("KEY_LEFT_CLICK_EXPLAIN"))
	draw_string(global.font, Vector2(8, 32), tr("KEY_RIGHT_CLICK_EXPLAIN"))
	draw_string(global.font, Vector2(8, 48), tr("KEY_WHEEL_EXPLAIN"))
	pass


func xform(pos):
	return global.texture_size / 2 + (pos - cam_offset) / zoom

func _on_RenderTab_render_size_updated(value):
	render_rect = value
	update()
	pass
	
func reset_view():
	zoom = 1.0
	pan = Vector2()
	cam_offset = Vector2()
	prev_cam_offset = Vector2()
	drag_offset = Vector2()
	emit_signal("reset_camera")

func load_bg():
	BgImageDialog.popup_centered()
	pass

func choose_bg_color():
	color_picker.connect("color_changed", self, "_on_ColorPicker_color_changed")
	
	ColourSelector.get_node("ColorSelector").popup_centered()
	pass
	
func _on_ColorPicker_color_changed(color):
	global.show_bg_color = true
	global.bg_color = color
	
	

func clear_bg():
	global.show_bg_color = false
	global.show_bg_tex = false
	
	
	pass

func _on_BgImageDialog_file_selected(path):
	global.show_bg_tex = true
	global.bg_image.load(path)
	global.bg_tex = ImageTexture.new()
	global.bg_tex.create_from_image(global.bg_image)
	global.bg_tex.flags = 0
	
	
	pass


func _on_Control_reset_camera():
	zoom = 1.0
	cam_offset = Vector2(0, 0)
	prev_cam_offset = Vector2(0, 0)
	pan = Vector2(0, 0)
	pass


func _on_Particle_Editor_camera_setup(pos, z, p):
	zoom = z.x
	pan = p
	cam_offset = pos
	prev_cam_offset = pos
	update()
	pass
