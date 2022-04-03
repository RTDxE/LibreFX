extends Control





signal emitter_changed
signal emitter_value_changed
signal enable_properties
signal update
signal stop_emitting
signal start_emitting
signal camera_setup
signal render_finished
signal burst
var playing = true
var current_emitter
var emitter_number = 0
var emitter_scene = preload("res://GPUEmitter.tscn")
var lock_icon = preload("res://locked.png")

var render_framecount = 60
var output_image = Image.new()
var output_width = 0
var output_height = 0
var render_fps = 60
var render_scale = 100.0
var render_wait = 0

var rendering = false
var render_time = 0
var current_frame = 0
var progress_bar
var output_type = 0

var preview_tex = ImageTexture.new()
var cam
var vp
var gui_items = {}
func _ready():
	vp = find_node("Viewport")
	progress_bar = find_node("RenderProgress")
	$HBox / VBoxContainer2 / HBoxContainer / VBoxContainer / HBoxContainer / VBoxContainer / ViewportContainer / Viewport.size = global.texture_size
	cam = $HBox / VBoxContainer2 / HBoxContainer / VBoxContainer / HBoxContainer / VBoxContainer / ViewportContainer / Viewport / Camera2D
	
	
	
	
	get_controls(self)
	
	_on_AddEmitter_pressed()
	global.history.clear_history()
	
	pass

func get_controls(node):
	for i in node.get_children():
		gui_items[i.name] = i
		get_controls(i)
		

func _process(delta):
	if playing == true:
		emit_signal("update", delta)
		
	
		
			
			
			
				
				
		
	pass


func _on_OptionButton_item_selected(ID):
	match (ID):
		0:
			$HBoxContainer / Panel3 / VBoxContainer / Value.visible = true
			$HBoxContainer / Panel3 / VBoxContainer / MinMax.visible = false
			$HBoxContainer / Panel3 / VBoxContainer / Curve.visible = false
		1:
			$HBoxContainer / Panel3 / VBoxContainer / Value.visible = false
			$HBoxContainer / Panel3 / VBoxContainer / MinMax.visible = false
			$HBoxContainer / Panel3 / VBoxContainer / Curve.visible = true
		2:
			$HBoxContainer / Panel3 / VBoxContainer / Value.visible = false
			$HBoxContainer / Panel3 / VBoxContainer / MinMax.visible = true
			$HBoxContainer / Panel3 / VBoxContainer / Curve.visible = false
	pass

func add_emitter(name):
	var e = emitter_scene.instance()
	
	e.position = Vector2()
	e.orig_pos = e.position
	if name:
		e.emitter_name = name
	else :
		e.emitter_name += str(emitter_number)
		
	
	
	
	

	global.history.create_action("Add Emitter")
	global.history.add_do_method(e, "connect", "value_changed", self, "emitter_value_changed")
	global.history.add_undo_method(e, "disconnect", "value_changed", self, "emitter_value_changed")
	global.history.add_do_method(self, "connect", "update", e, "process_emitter")
	global.history.add_undo_method(self, "disconnect", "update", e, "process_emitter")
	global.history.add_do_method(self, "connect", "stop_emitting", e, "stop")
	global.history.add_undo_method(self, "disconnect", "stop_emitting", e, "stop")
	global.history.add_do_method(self, "connect", "start_emitting", e, "start")
	global.history.add_undo_method(self, "disconnect", "start_emitting", e, "start")
	global.history.add_do_method(self, "connect", "burst", e, "burst")
	global.history.add_undo_method(self, "disconnect", "burst", e, "burst")
	global.history.add_do_method(vp, "add_child", e)
	global.history.add_undo_method(vp, "remove_child", e)
	global.history.add_do_method(global, "emitters_pushback", weakref(e))
	global.history.add_undo_method(global, "emitters_remove_last")
	global.history.add_do_property(self, "emitter_number", emitter_number + 1)
	global.history.add_undo_property(self, "emitter_number", emitter_number)
	global.history.add_do_method(self, "update_emitter_list", true)
	global.history.add_undo_method(self, "update_emitter_list", true)
	global.history.add_do_reference(e)
	global.history.commit_action()
	
	
	
	
	return e
	
func lol(text):
	print(text)

func duplicate_emitter():
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	create_emitter_from_dict("", emitter.get_dict(""))
	emitter = current_emitter.get_ref()
	emitter.emitter_name += "_copy"
	update_emitter_list(true)

func update_emitter_list(select_last = false):
	var list = find_node("EmitterList")
	var selected = list.get_selected_items()
	if selected.size() > 0:
		selected = selected[0]
	else :
		selected = 0
	list.clear()
	for i in range(0, global.emitters.size()):
		var e = global.emitters[i].get_ref()
		if e:
			list.add_item(e.emitter_name, lock_icon if e.locked else null)
			e.index = i
	if global.emitters.size() > 0:
		selected = clamp(selected, 0, global.emitters.size() - 1)
		list.select(selected)
		if select_last:
			list.select(global.emitters.size() - 1)
			selected = global.emitters.size() - 1
		_on_EmitterDropdown_item_selected(selected)
	else :
		_on_EmitterDropdown_item_selected( - 1)
	yield (get_tree(), "idle_frame")
	list.get_v_scroll().value = 1000

func _on_AddEmitter_pressed(name = ""):
	current_emitter = weakref(add_emitter(name))
	pass
	
func clear_emitters():
	emitter_number = 0
	for i in global.emitters:
		var e = i.get_ref()
		if not e:
			continue
		e.cleanup_and_remove()
	global.emitters.clear()
	update_emitter_list()
	pass

func _on_Particle_Editor_emitter_changed(e):
	if not e:
		return 
	var emitter = e.get_ref()
	if not e:
		return 
	gui_items["LocalParticles"].pressed = emitter.local
	gui_items["LoopEmitter"].pressed = not emitter.one_shot
	gui_items["SeamlessLoop"].pressed = emitter.seamless
	gui_items["Visibility"].pressed = emitter.visibility
	gui_items["Locked"].pressed = emitter.locked
	gui_items["BlendOption"].select(emitter.blend_mode)
	gui_items["LayerValue"].value = emitter.z_index
	gui_items["EmitterName"].text = emitter.emitter_name
	pass

func _on_RemoveEmitter_pressed():
	var list = find_node("EmitterList")
	var index = - 1
	if list.items.size() > 0:
			index = list.get_selected_items()[0]
	if index < 0:
		return 
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
		
	global.history.create_action("Remove Emitter")
	global.history.add_do_method(vp, "remove_child", emitter)
	global.history.add_undo_method(vp, "add_child", emitter)
	global.history.add_undo_reference(emitter)
	global.history.add_do_method(global, "emitters_remove", index)
	global.history.add_undo_method(global, "emitters_add", index, emitter)
	global.history.add_undo_reference(emitter)
	global.history.add_do_method(self, "update_emitter_list")
	global.history.add_undo_method(self, "update_emitter_list")
	
	global.history.add_undo_method(emitter, "connect", "value_changed", self, "emitter_value_changed")
	global.history.add_do_method(emitter, "disconnect", "value_changed", self, "emitter_value_changed")
	global.history.add_undo_method(self, "connect", "update", emitter, "process_emitter")
	global.history.add_do_method(self, "disconnect", "update", emitter, "process_emitter")
	global.history.add_undo_method(self, "connect", "stop_emitting", emitter, "stop")
	global.history.add_do_method(self, "disconnect", "stop_emitting", emitter, "stop")
	global.history.add_undo_method(self, "connect", "start_emitting", emitter, "start")
	global.history.add_do_method(self, "disconnect", "start_emitting", emitter, "start")
	global.history.add_undo_method(self, "connect", "burst", emitter, "burst")
	global.history.add_do_method(self, "disconnect", "burst", emitter, "burst")
	
	global.history.commit_action()
	
	
	

func _on_EmitterDropdown_item_selected(ID):
	if ID < 0:
		emit_signal("enable_properties", false)
		return 
	emit_signal("enable_properties", true)
	current_emitter = global.emitters[ID]
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	emitter.gui = {}
	emit_signal("emitter_changed", current_emitter)
	pass


func _on_LocalParticles_toggled(button_pressed):
	var emitter = current_emitter.get_ref()
	if emitter:
		global.history.create_action("Set local particles")
		global.history.add_do_method(emitter, "set_prop", "local", button_pressed)
		global.history.add_undo_method(emitter, "set_prop", "local", emitter.get_prop("local"))
		global.history.add_do_property(find_node("LocalParticles"), "pressed", button_pressed)
		global.history.add_undo_property(find_node("LocalParticles"), "pressed", emitter.get_prop("local"))
		global.history.commit_action()
	pass


func _on_LoopEmitter_toggled(button_pressed):
	var emitter = current_emitter.get_ref()
	if emitter:
		
		global.history.create_action("Set loop particles")
		global.history.add_do_method(emitter, "set_prop", "one_shot", not button_pressed)
		global.history.add_undo_method(emitter, "set_prop", "one_shot", emitter.get_prop("one_shot"))
		global.history.add_do_property(find_node("LoopEmitter"), "pressed", button_pressed)
		global.history.add_undo_property(find_node("LoopEmitter"), "pressed", not emitter.get_prop("one_shot"))
		global.history.commit_action()
	pass


func _on_BlendOption_item_selected(ID):
	var emitter = current_emitter.get_ref()
	if emitter:
		global.history.create_action("Blendmode changed")
		global.history.add_do_method(emitter, "set_blend_mode", ID)
		global.history.add_undo_method(emitter, "set_blend_mode", emitter.blend_mode)
		global.history.add_do_method(find_node("BlendOption"), "select", ID)
		global.history.add_undo_method(find_node("BlendOption"), "select", emitter.blend_mode)
		global.history.commit_action()
		

func _on_Start_pressed():
	emit_signal("start_emitting")
	pass


func _on_LayerValue_value_changed(value):
	var emitter = current_emitter.get_ref()
	if emitter:
		global.history.create_action("Layer changed")
		global.history.add_do_method(emitter, "set_prop", "layer", value)
		global.history.add_undo_method(emitter, "set_prop", "layer", emitter.get_prop("layer"))
		global.history.add_do_property(find_node("LayerValue").get_line_edit(), "text", str(value))
		global.history.add_undo_property(find_node("LayerValue").get_line_edit(), "text", str(emitter.get_prop("layer")))
		global.history.commit_action()
		
	pass

	
func save_output(path):
	if output_type == 0:
		if path.substr(len(path) - 4, 4) != ".png":
			InfoDialog.show_info("Error: Please choose a valid filename (*.png)")
			return 
			
		if render_scale < 100.0:
			output_image.resize(output_width * (render_scale / 100.0), output_height * (render_scale / 100.0), 0)
		output_image.save_png(path)
	elif output_type == 1:
		var base_name = path.get_basename()
		for i in range(0, render_framecount):
			var temp_frame = Image.new()
			temp_frame.create(global.render_size.x, global.render_size.y, false, Image.FORMAT_RGBA8)
			var frames_per_row = output_width / global.render_size.x
			var y = floor(i / frames_per_row) * global.render_size.y
			var x = floor(fmod(i, frames_per_row)) * global.render_size.x
			temp_frame.blit_rect(output_image, Rect2(x, y, global.render_size.x, global.render_size.y), Vector2(0, 0))
			if render_scale < 100.0:
				yield (get_tree(), "idle_frame")
				temp_frame.resize(global.render_size.x * (render_scale / 100.0), global.render_size.y * (render_scale / 100.0), 0)
			temp_frame.save_png(base_name + str(i) + ".png")
			
	elif output_type == 2:
		var base_name = path.get_basename()
		var temp_frame = Image.new()
		temp_frame.create(global.render_size.x, global.render_size.y, false, Image.FORMAT_RGBA8)
		var frames_per_row = output_width / global.render_size.x
		var y = floor(current_frame / frames_per_row) * global.render_size.y
		var x = floor(fmod(current_frame, frames_per_row)) * global.render_size.x
		temp_frame.blit_rect(output_image, Rect2(x, y, global.render_size.x, global.render_size.y), Vector2(0, 0))
		if render_scale < 100.0:
			yield (get_tree(), "idle_frame")
			temp_frame.resize(global.render_size.x * (render_scale / 100.0), global.render_size.y * (render_scale / 100.0), Image.INTERPOLATE_NEAREST)
		temp_frame.save_png(path)
			
	elif output_type == 3:
		
		
		for i in range(0, render_framecount):
			var temp_frame = Image.new()
			temp_frame.create(global.render_size.x, global.render_size.y, false, Image.FORMAT_RGBA8)
			var frames_per_row = output_width / global.render_size.x
			var y = floor(i / frames_per_row) * global.render_size.y
			var x = floor(fmod(i, frames_per_row)) * global.render_size.x
			temp_frame.blit_rect(output_image, Rect2(x, y, global.render_size.x, global.render_size.y), Vector2(0, 0))
			if render_scale < 100.0:
				yield (get_tree(), "idle_frame")
				temp_frame.resize(global.render_size.x * (render_scale / 100.0), global.render_size.y * (render_scale / 100.0), Image.INTERPOLATE_NEAREST)
			
			
		
	
func _on_RenderButton_pressed():

	global.render_fps = render_fps
	playing = false
	output_width = clamp(global.render_size.x * render_framecount, 0, min(global.max_frames_per_row * global.render_size.x, 16384))
	output_height = max(global.render_size.y, ((ceil((global.render_size.x * render_framecount) / (output_width))) * global.render_size.y))
	var prev_diag = find_node("PreviewDialog")
	var prev_anim = find_node("PreviewAnim")
	prev_anim.tex_width = output_width
	prev_anim.tex_height = output_height
	output_image.create(output_width, output_height, false, Image.FORMAT_RGBA8)
	
	if not output_image:
		InfoDialog.show_info("Error: Unable to allocate memory for rendering!")
		return 
	
	emit_signal("stop_emitting")
	yield (get_tree(), "idle_frame")
	emit_signal("start_emitting")
	yield (get_tree(), "idle_frame")
	
	var tex
	
		
	if render_wait > 0:
		for i in range(0, render_wait):
			emit_signal("update", 1.0 / render_fps)
			yield (get_tree(), "idle_frame")
		
	for i in range(0, render_framecount):
		emit_signal("update", 1.0 / render_fps)
		yield (get_tree(), "idle_frame")

		var frames_per_row = output_width / global.render_size.x
		var y = floor(i / frames_per_row) * global.render_size.y
		var x = floor(fmod(i, frames_per_row)) * global.render_size.x
		
		tex = $HBox / VBoxContainer2 / HBoxContainer / VBoxContainer2 / HBoxContainer / VBoxContainer / PostPreview.texture
		output_image.blit_rect(tex.get_data(), Rect2((global.texture_size) / 2 - (global.render_size / 2), global.render_size), Vector2(x, y))
		progress_bar.value = (float(i + 1) / float(render_framecount)) * 100.0

	
	
	preview_tex.create_from_image(output_image, 0)
	prev_anim.set_tex(preview_tex)
	playing = true
	emit_signal("start_emitting")
	emit_signal("render_finished")
	prev_diag.rect_size = global.render_size * 1.2 + Vector2(0, 96)
	prev_diag.popup_centered()
	pass
		

func get_project_json(path):
	var dict = {}
	var emitters_list = []
	for i in global.emitters:
		var e = i.get_ref()
		emitters_list.push_back(e.get_dict(path))
	dict["emitters"] = emitters_list
	dict["effects"] = {"nodes":find_node("Effects").get_nodes(), "connections":find_node("Effects").get_connections()}
	dict["camera"] = get_cam_dict()
	dict["settings"] = find_node("RenderTab").get_render_settings()
	return to_json(dict)
	
	
func load_project_json(base_dir, data, import = false):
	var effects_tab = find_node("Effects")
	for i in data["emitters"]:
		create_emitter_from_dict(base_dir, i)
	if not import and data.has("effects"):
		effects_tab.create_effects_from_dict(data["effects"])
	if data.has("camera"):
		var pos = global.dict_to_vec(data["camera"]["position"])
		var zoom = global.dict_to_vec(data["camera"]["zoom"])
		var pan = global.dict_to_vec(data["camera"]["pan"])
		emit_signal("camera_setup", pos, zoom, pan)
	else :
		emit_signal("camera_setup", Vector2(), Vector2(1, 1), Vector2())
	if data.has("settings"):
		find_node("RenderTab").set_render_settings(data["settings"])
	else :
		find_node("RenderTab").set_default_settings()

	pass
	
	
func get_cam_dict():
	return cam.get_dict()
	pass
	
func create_emitter_from_dict(base_dir, dict):
	current_emitter = weakref(add_emitter(dict["name"]))
	var e = current_emitter.get_ref()
	if not e:
		return 
		
	
	e.emitter_name = global.try_value(dict, "name", "Emitter")
	e.position = global.dict_to_vec(global.try_value(dict, "position", {"x":256, "y":256}))
	e.local = global.try_value(dict, "local", false)
	e.one_shot = global.try_value(dict, "one_shot", false)
	e.seamless = global.try_value(dict, "seamless", false)
	e.visibility = global.try_value(dict, "visibility", true)
	e.locked = global.try_value(dict, "locked", false)
	e.blend_mode = global.try_value(dict, "blend_mode", 0)
	e.layer = global.try_value(dict, "layer", 0)

	for i in global.try_key(dict, "p_properties"):
		
		var prop = i
		var prop_dict = global.try_key(dict["p_properties"], i)
		var var_type = global.try_value(prop_dict, "var_type", 0)
		
		var value = global.try_value(prop_dict, "value", 0)
		match (typeof(var_type)):
			2, 3:
				match (int(var_type)):
					TYPE_INT, TYPE_REAL:
						e.set_prop(prop, value)
					TYPE_VECTOR2:
						e.set_prop(prop, global.dict_to_vec(value))
					TYPE_RECT2:
						e.set_prop(prop, global.dict_to_rect(value))
					TYPE_BOOL:
						e.set_prop(prop, value)
			4:
				match (var_type):
					"curve":
						e.set_prop(prop, global.dict_to_curve(prop_dict))
					"gradient":
						e.set_prop(prop, global.dict_to_gradient(value))
					"texture":
						var filtered = global.try_key(prop_dict, "filtered")
						var relative = global.try_key(prop_dict, "relative")
						e.set_prop(prop, global.load_texture(value, filtered, relative, base_dir))

	emit_signal("emitter_changed", current_emitter)
						

func _on_LanguageMenu_lang_updated():
	update_emitter_list()
	emit_signal("emitter_changed", current_emitter)
	pass



func _on_RenderTab_render_fps_updated(value):
	render_fps = value
	pass


func _on_RenderTab_render_framecount_updated(value):
	render_framecount = value
	pass


func _on_SaveButton_pressed():
	if ProjectSettings.get_setting("global/export"):
		if output_image.get_size().x < 1 or output_image.get_size().y < 1:
			InfoDialog.show_info("Error: Render image is empty")
			return 
		var diag = find_node("RenderOutputDialog")
		match (output_type):
			0:
				diag.window_title = tr("SAVE_SPRITE_SHEET")
				diag.filters = ["*.png"]
				diag.current_file = ""
			1:
				diag.window_title = tr("SAVE_MULTIPLE_IMAGES")
				diag.filters = ["*.png"]
				diag.current_file = ""
			2:
				diag.window_title = tr("SAVE_CURRENT_FRAME")
				diag.filters = ["*.png"]
				diag.current_file = ""
			3:
				diag.window_title = tr("SAVE_GIF_IMAGE")
				diag.filters = ["*.gif"]
				diag.current_file = ""
		diag.popup_centered()
	else :
		InfoDialog.show_info("Not available in the demo version.\nBlastFX can be purchased at the link below:\n\n [url=http://benhickling.itch.io/blastfx]BlastFX Homepage[/url]")
	pass
	
func sorry():
	InfoDialog.show_info("This feature is disabled in the demo")


func _on_RenderOutputDialog_file_selected(path):
	save_output(path)
	pass


func _on_RenderTab_render_scale_updated(value):
	render_scale = value
	pass



func _on_EmitterName_text_entered(new_text):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	global.history.create_action("Change emitter name")
	global.history.add_do_property(emitter, "emitter_name", new_text)
	global.history.add_undo_property(emitter, "emitter_name", emitter.emitter_name)
	global.history.add_do_method(self, "update_emitter_list")
	global.history.add_undo_method(self, "update_emitter_list")
	global.history.commit_action()
	emitter.emitter_name = new_text
	update_emitter_list()
	pass


func _on_Start2_pressed():
	emit_signal("burst")
	pass
	

func _on_DuplicateEmitter_pressed():
	duplicate_emitter()
	pass


func _on_PropertyGrid_value_changed(prop, value, callback = ""):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	emitter.update_property_value(prop, value)
	if callback:
		emitter.call(callback, prop, value)
	pass


func _on_PropertyGrid_type_changed(prop, type, control):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	emitter.update_value_type(prop, type, control)
	pass


func _on_PropertyGrid_vector_type_changed(prop, type, control):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	emitter.update_vector_type(prop, type, control)
	pass


func _on_PlaySingle_pressed():
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	emitter.start()
	pass


func _on_ViewportContainer_emitter_changed(e):
	if e:
		e = e.get_ref()
	else :
		return 
	_on_EmitterDropdown_item_selected(e.index)
	find_node("EmitterList").select(e.index)
	pass


func _on_SeamlessLoop_toggled(button_pressed):
	var emitter = current_emitter.get_ref()
	if emitter:
		if button_pressed:
			find_node("RenderTab").set_seamless(emitter.lifetime)
			emitter.update_property_value("preprocess", emitter.lifetime)
		global.history.create_action("Set seamless loop")
		global.history.add_do_method(emitter, "set_prop", "seamless", button_pressed)
		global.history.add_undo_method(emitter, "set_prop", "seamless", emitter.get_prop("seamless"))
		global.history.add_do_property(find_node("SeamlessLoop"), "pressed", button_pressed)
		global.history.add_undo_property(find_node("SeamlessLoop"), "pressed", emitter.get_prop("seamless"))
		global.history.commit_action()
		
	pass


func _on_RenderTab_render_wait_updated(value):
	render_wait = value
	pass


func _on_SaveType_item_selected(ID):
	output_type = ID
	pass


func _on_Control_undo():
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	emitter.gui = {}
	emit_signal("emitter_changed", current_emitter)
	pass


func _on_Control_redo():
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	emitter.gui = {}
	emit_signal("emitter_changed", current_emitter)
	pass

func emitter_value_changed(prop, value):
	emit_signal("emitter_value_changed", prop, value)

func _on_FrameSlider_value_changed(value):
	current_frame = value
	pass


func _on_Visibility_toggled(button_pressed):
	var emitter = current_emitter.get_ref()
	if emitter:
		global.history.create_action("Set Visibility")
		global.history.add_do_method(emitter, "set_prop", "visibility", button_pressed)
		global.history.add_undo_method(emitter, "set_prop", "visibility", emitter.get_prop("visibility"))
		global.history.add_do_property(find_node("Visibility"), "pressed", button_pressed)
		global.history.add_undo_property(find_node("Visibility"), "pressed", emitter.get_prop("visibility"))
		global.history.commit_action()



func _on_Locked_toggled(button_pressed):
	var emitter = current_emitter.get_ref()
	if emitter:
		global.history.create_action("Set Locked")
		global.history.add_do_method(emitter, "set_prop", "locked", button_pressed)
		global.history.add_undo_method(emitter, "set_prop", "locked", emitter.get_prop("locked"))
		global.history.add_do_property(find_node("Locked"), "pressed", button_pressed)
		global.history.add_undo_property(find_node("Locked"), "pressed", emitter.get_prop("locked"))
		global.history.commit_action()
		update_emitter_list(false)
	pass
