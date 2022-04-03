extends HBoxContainer




signal render_size_updated
signal render_fps_updated
signal render_framecount_updated
signal render_scale_updated
signal render_wait_updated

var render_scale = 100.0
var render_fps = 60


var max_frames = 60
export (String) var title

func _ready():
	$CanvasLayer / RenderOutputDialog.filters = ["*.png"]
	max_frames = floor(2.68435e+08 / (global.render_size.x * global.render_size.y))
	find_node("FrameAmount").max_value = max_frames
	update_tex_size_label()
	pass






func _on_RenderWidth_value_changed(value):
	global.render_size.x = value
	
	
	max_frames = (min(global.max_frames_per_row * global.render_size.x, 16384.0) / global.render_size.x) * 16384.0 / global.render_size.y
	find_node("FrameAmount").max_value = max_frames
	find_node("MaxFramesPerRow").max_value = 16384 / global.render_size.x
	emit_signal("render_size_updated", global.render_size)
	update_tex_size_label()
	pass


func _on_RenderHeight_value_changed(value):
	global.render_size.y = value
	
	
	max_frames = (min(global.max_frames_per_row * global.render_size.x, 16384.0) / global.render_size.x) * 16384.0 / global.render_size.y
	find_node("FrameAmount").max_value = max_frames
	emit_signal("render_size_updated", global.render_size)
	update_tex_size_label()
	pass


func _on_RenderFPS_value_changed(value):
	render_fps = value
	emit_signal("render_fps_updated", render_fps)
	pass


func _on_FrameAmount_value_changed(value):
	global.frame_amount = value
	emit_signal("render_framecount_updated", global.frame_amount)
	update_tex_size_label()
	pass


func _on_RenderScale_value_changed(value):
	render_scale = value
	update_tex_size_label()
	emit_signal("render_scale_updated", render_scale)
	pass
	
func update_tex_size_label():
	find_node("TextureSizeLabel").text = tr("RENDER_TEX_SIZE") + ": " + calc_size()

func calc_size():
	var output_width = clamp(global.render_size.x * global.frame_amount, 0, min(global.max_frames_per_row * global.render_size.x, 16384))
	var output_height = (ceil((global.render_size.x * global.frame_amount) / (output_width)) * global.render_size.y)
	return str(int(output_width * (render_scale / 100.0))) + " x " + str(int(output_height * (render_scale / 100.0)))

func _on_CanvasWidth_value_changed(value):
	
	pass


func _on_RenderButton_pressed():
	$MarginContainer / PanelContainer / HBoxContainer / VBoxContainer / MarginContainer / VBoxContainer / RenderButton.disabled = true
	
	pass


func _on_Particle_Editor_render_finished():
	$MarginContainer / PanelContainer / HBoxContainer / VBoxContainer / MarginContainer / VBoxContainer / RenderButton.disabled = false
	
	pass


func _on_RenderWait_value_changed(value):
	global.render_wait = value
	emit_signal("render_wait_updated", global.render_wait)
	pass


func _on_OutputMaxWidth_value_changed(value):
	global.max_frames_per_row = float(value)
	max_frames = (min(global.max_frames_per_row * global.render_size.x, 16384.0) / global.render_size.x) * 16384.0 / global.render_size.y
	find_node("FrameAmount").max_value = max_frames
	find_node("MaxFramesPerRow").max_value = 16384 / global.render_size.x
	update_tex_size_label()
	pass

func get_render_settings():
	var dict = {}
	dict["render_width"] = find_node("RenderWidth").value
	dict["render_height"] = find_node("RenderHeight").value
	dict["max_frames_per_row"] = find_node("MaxFramesPerRow").value
	dict["frame_amount"] = find_node("FrameAmount").value
	dict["render_fps"] = find_node("RenderFPS").value
	dict["render_wait"] = find_node("RenderWait").value
	
	
	return dict
	
func set_render_settings(dict):
	find_node("RenderWidth").value = global.try_value(dict, "render_width", 256)
	find_node("RenderHeight").value = global.try_value(dict, "render_height", 256)
	find_node("MaxFramesPerRow").value = global.try_value(dict, "max_frames_per_row", 64)
	find_node("FrameAmount").value = global.try_value(dict, "frame_amount", 60)
	find_node("RenderFPS").value = global.try_value(dict, "render_fps", 60)
	find_node("RenderWait").value = global.try_value(dict, "render_wait", 0)
	
	
	
func set_default_settings():
	find_node("RenderWidth").value = 256
	find_node("RenderHeight").value = 256
	find_node("MaxFramesPerRow").value = 64
	find_node("FrameAmount").value = 60
	find_node("RenderFPS").value = 60
	find_node("RenderWait").value = 0
	
func set_seamless(lifetime):
	find_node("FrameAmount").value = find_node("RenderFPS").value * lifetime
