extends TextureRect




signal emitter_changed
signal zoom_changed
signal pan_changed
signal pan_finished
signal reset_camera
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

export (NodePath) var bg_diag_path
var BgImageDialog
var bg_image = Image.new()
var bg_tex = ImageTexture.new()


func _ready():
	BgImageDialog = get_node(bg_diag_path)
	if not BgImageDialog:
		assert ("Invalid BG Image Dialog node path!")
	pass


func _process(delta):
	update()

func _gui_input(event):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	

		
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			zoom -= 0.1 * zoom
			zoom = clamp(zoom, 0.1, 4.0)
			if zoom > 0.95 and zoom < 1.05:
				zoom = 1.0
			emit_signal("zoom_changed", zoom)
			
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			zoom += 0.1 * zoom
			zoom = clamp(zoom, 0.1, 4.0)
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
		
	if not dragging:
		under_mouse = []
		for i in global.emitters:
			var ref = i.get_ref()
			if ref:
				var emitter_rect = Rect2(global.texture_size / 2 + ((ref.position - cam_offset) / zoom), Vector2(1, 1)).grow(16 / zoom)
				if event is InputEventMouseButton:
					if emitter_rect.has_point(event.position):
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
				if emitter_rect.has_point(event.position) and not dragging:
					if event.is_pressed() and event.button_index == BUTTON_MASK_LEFT:
						dragging = true
						ref.dragging = true
						drag_offset = ((global.texture_size / 2 + ((ref.position - cam_offset) / zoom)) - event.position)
						emit_signal("emitter_changed", selected)
					
				if not event.is_pressed() and event.button_index == BUTTON_MASK_LEFT:
					dragging = false
					ref.dragging = false
					emit_signal("emitter_changed", selected)
									
			if event is InputEventMouseMotion:
				
				if dragging and ref.dragging:
					ref.position = ((((event.position + cam_offset / zoom) - global.texture_size / 2) + drag_offset) * zoom)
					ref.orig_pos = ref.position
					update()

					
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
	
	draw_texture(texture, Vector2(0, 0))
	draw_rect(Rect2(Vector2(1, 0), get_rect().size - Vector2(1, 1)), Color(1, 1, 1, 0.5), false)
	
	draw_rect(Rect2((global.texture_size) / 2 - (render_rect / 2), render_rect + Vector2(1, 1)), Color(0, 0, 0, 1), false)
	draw_rect(Rect2((global.texture_size) / 2 - (render_rect / 2), render_rect), Color(1, 1, 1, 1), false)
	draw_string(global.font, global.texture_size / 2 + Vector2( - global.font.get_string_size(tr("KEY_RENDER_FRAME_LABEL")).x / 2, render_rect.y / 2 + 12), tr("KEY_RENDER_FRAME_LABEL"))
	
	if not current_emitter:
		return 
	var emitter = current_emitter.get_ref()
	for i in global.emitters:
		var ref = i.get_ref()
		if ref:
			draw_rect(Rect2(xform(ref.position) + Vector2(1, 1), Vector2(1, 1)).grow(16 / zoom), Color(0, 0, 0, 0.5), false)
			draw_rect(Rect2(xform(ref.position), Vector2(1, 1)).grow(16 / zoom), Color(1, 1, 1, 0.5), false)
	
	if emitter:
		
		draw_line(xform(emitter.position), xform(emitter.position) + Vector2(0, 64 / zoom).rotated(emitter.rotation), Color(1, 1, 1, 1))
		
		var nb_points = 32
		var points_arc = PoolVector2Array()
		var center = xform(emitter.position)
		points_arc.push_back(center)
		var colors = PoolColorArray([Color(1, 1, 1, 0.3)])
		var angle_from = emitter.rotation_degrees - emitter.get_value(emitter.p_spread)
		var angle_to = emitter.rotation_degrees + emitter.get_value(emitter.p_spread)
		for i in range(nb_points + 1):
			var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points + 90)
			points_arc.push_back(center + Vector2(1, 0).rotated(angle_point) * 64 / zoom)
		draw_polygon(points_arc, colors)
		
		
		draw_rect(Rect2(xform(emitter.position) + Vector2(1, 1), Vector2(1, 1)).grow(16 / zoom), Color(0, 0, 0, 1), false)
		draw_rect(Rect2((global.texture_size / 2 + (emitter.position - cam_offset) / zoom), Vector2(1, 1)).grow(16 / zoom), Color(1, 1, 1, 1), false)
		draw_string(global.font, xform(emitter.position) - Vector2(global.font.get_string_size(emitter.emitter_name).x / 2, 18 / zoom), emitter.emitter_name)
		
			
	
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

func _on_LoadBG_pressed():
	BgImageDialog.popup_centered()
	pass


func _on_BgImageDialog_file_selected(path):
	bg_image.load(path)
	bg_tex = ImageTexture.new()
	bg_tex.create_from_image(bg_image)
	pass
