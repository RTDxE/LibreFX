extends "res://Nodes/effect_node.gd"




var color_rect = preload("res://ColorRect.tscn")
var pal_tex
var pal_image
var current_item
var colour_picker

var palette_ui
var file_diag

var prev_dither
var prev_alpha
var prev_color = Color(1, 1, 1, 1)

var dir_path

func _ready():
	dir_path = global.res_path + "palettes/"
	load_presets()
	palette_ui = find_node("Palette")
	file_diag = find_node("FileDialog")
	file_diag.filters = ["*.pal;JASC Palette", "*.gpl;GIMP Palette"]
	file_diag.current_dir = dir_path
	colour_picker = ColourSelector.get_node("ColorSelector/ColorPicker")
	pal_tex = ImageTexture.new()
	pal_tex.create(256, 1, Image.FORMAT_RGBA8, 0)
	pal_image = Image.new()
	pal_image.create(256, 1, false, Image.FORMAT_RGBA8)

	pal_image.lock()
	pal_image.set_pixel(0, 0, Color(1, 1, 1, 1))
	pal_image.unlock()
	pal_tex.set_data(pal_image)
	$Viewport / TextureRect.material.set_shader_param("palette", pal_tex)
	add_color_rect(Color(0, 0, 0, 1))
	add_color_rect(Color(0.5, 0.5, 0.5, 1))
	add_color_rect(Color(1, 1, 1, 1))
	$Viewport / TextureRect.material.set_shader_param("tex_size", global.texture_size)
	$Viewport / TextureRect.material.set_shader_param("dither_amount", $GridContainer / DitherSlider.value)
	$Viewport / TextureRect.material.set_shader_param("alpha_threshold", $GridContainer / AlphaSlider.value)
	
	prev_dither = $GridContainer / DitherSlider.value
	prev_alpha = $GridContainer / AlphaSlider.value

	pass





func get_values():
	var dict = {}
	dict["dither"] = $GridContainer / DitherSlider.value
	dict["alpha"] = $GridContainer / AlphaSlider.value
	dict["colors"] = []
	for col in palette_ui.get_children():
		if col is ColorRect:
			dict["colors"].push_back(global.color_to_dict(col.color))
	return dict
	
func set_values(dict):
	clear_colors(false)
	$GridContainer / DitherSlider.value = global.try_value(dict, "dither", 0)
	$GridContainer / AlphaSlider.value = global.try_value(dict, "alpha", 0)
	$Viewport / TextureRect.material.set_shader_param("dither_amount", global.try_value(dict, "dither", 0))
	$Viewport / TextureRect.material.set_shader_param("alpha_threshold", global.try_value(dict, "alpha", 0))
	for i in dict["colors"]:
		add_color_rect(global.dict_to_color(i))
	yield (get_tree(), "idle_frame")
	build_texture()

func _on_DitherSlider_value_changed(value):
	global.history.create_action("Dither changed")
	global.history.add_do_property($GridContainer / DitherSlider, "value", value)
	global.history.add_undo_property($GridContainer / DitherSlider, "value", prev_dither)
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "dither_amount", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "dither_amount", prev_dither)
	global.history.add_do_property(self, "prev_dither", value)
	global.history.add_undo_property(self, "prev_dither", prev_dither)
	global.history.commit_action()
	
	pass


func _on_AlphaSlider_value_changed(value):
	global.history.create_action("Alpha changed")
	global.history.add_do_property($GridContainer / AlphaSlider, "value", value)
	global.history.add_undo_property($GridContainer / AlphaSlider, "value", prev_alpha)
	global.history.add_do_method($Viewport / TextureRect.material, "set_shader_param", "alpha_threshold", value)
	global.history.add_undo_method($Viewport / TextureRect.material, "set_shader_param", "alpha_threshold", prev_alpha)
	global.history.add_do_property(self, "prev_alpha", value)
	global.history.add_undo_property(self, "prev_alpha", prev_alpha)
	global.history.commit_action()
	
	pass



func get_previous_color(index):
	var child_count = palette_ui.get_child_count()
	if child_count > 2:
		if index > 0:
			current_item = palette_ui.get_child(index - 1)
		else :
			current_item = palette_ui.get_child(index)
		
func remove_rect(rect):
	if palette_ui.get_child_count() > 2:
		global.history.create_action("Remove colour")
		var removed_index = rect.get_index()
		var index = current_item.get_index() + 1
		if removed_index == 0:
			current_item = palette_ui.get_child(0)
			index = current_item.get_index()
			
		global.history.add_do_method(palette_ui, "remove_child", rect)
		global.history.add_undo_method(palette_ui, "add_child", rect)
		global.history.add_undo_method(palette_ui, "move_child", rect, index)
		global.history.add_undo_reference(rect)
		
		
		global.history.add_do_method(self, "build_texture")
		global.history.add_undo_method(self, "build_texture")
		
		
		
		global.history.commit_action()
	rect_size = Vector2(0, 0)


func _on_ColorRect_color_change(item, col, index):
	if item:
		current_item = item
	else :
		get_previous_color(index)
		return 
	colour_picker.edit_alpha = false
	
	colour_picker.connect("color_changed", self, "_on_ColorPicker_color_picked")
	colour_picker.color = col
	ColourSelector.get_node("ColorSelector").popup(Rect2(item.get_global_position() + Vector2(24, 0), Vector2(306, 466)))
	build_texture()
	pass


func _on_ColorPicker_color_picked(color):
	if current_item:
		global.history.create_action("Color changed")
		global.history.add_do_property(current_item, "color", color)
		global.history.add_undo_property(current_item, "color", current_item.prev_color)
		global.history.add_do_property(current_item, "prev_color", color)
		global.history.add_undo_property(current_item, "prev_color", prev_color)
		global.history.add_do_method(self, "build_texture")
		global.history.add_undo_method(self, "build_texture")
		global.history.commit_action()
		
		
	pass

func _on_ColorPicker_color_changed(color):
	if current_item:
		current_item.color = color
		build_texture()
	pass


func _on_AddButton_pressed():
	add_color_rect(Color(1, 1, 1, 1), true)
	pass

func add_color_rect(col, undo = false):
	var new_rect = color_rect.instance()
	if undo:
		global.history.create_action("Add color")
		global.history.add_do_method(palette_ui, "add_child", new_rect)
		global.history.add_undo_method(palette_ui, "remove_child", new_rect)
		global.history.add_do_reference(new_rect)
		global.history.add_do_method(new_rect, "connect", "color_change", self, "_on_ColorRect_color_change")
		global.history.add_do_method(new_rect, "connect", "remove_me", self, "remove_rect")
		global.history.add_undo_method(new_rect, "disconnect", "color_change", self, "_on_ColorRect_color_change")
		global.history.add_undo_method(new_rect, "disconnect", "remove_me", self, "remove_rect")
		global.history.add_do_property(self, "current_item", new_rect)
		global.history.add_undo_property(self, "current_item", current_item)
		global.history.add_do_method(palette_ui, "move_child", palette_ui.get_node("AddButton"), palette_ui.get_child_count())
		global.history.add_undo_method(palette_ui, "move_child", palette_ui.get_node("AddButton"), palette_ui.get_node("AddButton").get_index())
		global.history.add_do_property(new_rect, "color", col)
		global.history.add_do_property(new_rect, "prev_color", col)
		
		global.history.add_do_method(self, "build_texture")
		global.history.add_undo_method(self, "build_texture")
		global.history.commit_action()
	else :
		palette_ui.add_child(new_rect)
		new_rect.connect("color_change", self, "_on_ColorRect_color_change")
		new_rect.connect("remove_me", self, "remove_rect")
		current_item = new_rect
		palette_ui.move_child(palette_ui.get_node("AddButton"), palette_ui.get_child_count())
		current_item.color = col
		current_item.prev_color = col
		build_texture()
	pass
	
	
func add_colour_rect_multi(col, index):
	var new_rect = color_rect.instance()
	global.history.add_do_method(palette_ui, "add_child", new_rect)
	global.history.add_undo_method(palette_ui, "remove_child", new_rect)
	global.history.add_do_reference(new_rect)
	global.history.add_do_method(new_rect, "connect", "color_change", self, "_on_ColorRect_color_change")
	global.history.add_do_method(new_rect, "connect", "remove_me", self, "remove_rect")
	global.history.add_undo_method(new_rect, "disconnect", "color_change", self, "_on_ColorRect_color_change")
	global.history.add_undo_method(new_rect, "disconnect", "remove_me", self, "remove_rect")
	global.history.add_do_property(self, "current_item", new_rect)
	global.history.add_undo_property(self, "current_item", current_item)
	global.history.add_do_method(palette_ui, "move_child", palette_ui.get_node("AddButton"), index)
	global.history.add_undo_method(palette_ui, "move_child", palette_ui.get_node("AddButton"), palette_ui.get_node("AddButton").get_index())
	global.history.add_do_property(new_rect, "color", col)
	


func build_texture():
	if palette_ui.get_child_count() < 2:
		return 
	var x = 0
	var last_col
	var count = 0
	pal_image.lock()
	for col in palette_ui.get_children():
		if col is ColorRect:
			pal_image.set_pixel(clamp(x, 0, 256), 0, col.color)
			x += 1
			last_col = col.color
			count += 1
	for i in range(x, 256):
		pal_image.set_pixel(i, 0, last_col)
	pal_image.unlock()
	pal_tex.set_data(pal_image)
	$Viewport / TextureRect.material.set_shader_param("color_count", count)
	$Viewport / TextureRect.material.set_shader_param("palette", pal_tex)
	pass
	
	
func clear_colors(undo = false):
	if undo:
		
		for i in palette_ui.get_children():
			if i is ColorRect:
				
				global.history.add_do_method(palette_ui, "remove_child", i)
				global.history.add_undo_method(palette_ui, "add_child", i)
				global.history.add_undo_method(palette_ui, "move_child", i, i.get_index())
				global.history.add_undo_reference(i)
		
		
		
	else :
		for i in palette_ui.get_children():
			if i is ColorRect:
				i.queue_free()
		yield (get_tree(), "idle_frame")
	rect_size = Vector2(0, 0)
	pass
	
func load_palette(path):
	var ext = path.get_extension()
	match (ext):
		"pal":
			load_jasc(path)
		"gpl":
			load_gimp(path)
		_:
			InfoDialog.show_info("Error: Please select a valid JASC or GIMP palette file!")
			return 
	
func load_jasc(path):
	var file = File.new()
	if not file.file_exists(path):
		InfoDialog.show_info("Error: File does not exist!")
		return 
	var lines = []
	var err = file.open(path, File.READ)
	if err != 0:
		InfoDialog.show("Error: Unable to open file! Error Number: " + str(err))
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	
	if lines[0] != "JASC-PAL":
		InfoDialog.show_info("Please select a valid JASC palette file!")
		return 
	
	global.history.create_action("Load JASC palette")
	clear_colors(true)
	var index = 0
	var col_count = lines[2]
	for i in range(0, col_count):
		var r = lines[3 + i].substr(0, 3)
		var g = lines[3 + i].substr(4, 3)
		var b = lines[3 + i].substr(8, 3)
		index += 1
		print("R:" + r + " G:" + g + " B:" + b)
		add_colour_rect_multi(Color(int(r) / 255.0, int(g) / 255.0, int(b) / 255.0, 1.0), index)
	
	
	
	global.history.add_do_method(self, "build_texture")
	global.history.add_undo_method(self, "build_texture")
	global.history.commit_action()

	
func load_gimp(path):
	var file = File.new()
	if not file.file_exists(path):
		InfoDialog.show_info("Error: File does not exist!")
		return 
	var lines = []
	var err = file.open(path, File.READ)
	if err != 0:
		InfoDialog.show("Error: Unable to open file! Error Number: " + str(err))
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	
	if lines[0] != "GIMP Palette":
		InfoDialog.show_info("Please select a valid GIMP palette file!")
		return 
	
	global.history.create_action("Load GIMP palette")
	clear_colors(true)
	
	var index = 0
	for i in range(1, lines.size()):
		if lines[i].begins_with("#"):
			print("Skipping: " + lines[i])
			continue
		if lines[i] == "":
			print("Skipping: " + lines[i])
			continue
		if not lines[i].substr(0, 3).lstrip(" ").is_valid_integer():
			print("Not integer (" + lines[i].substr(0, 3).lstrip(" ") + ") , Skipping: " + lines[i])
			continue
		var r = lines[i].substr(0, 3)
		var g = lines[i].substr(4, 3)
		var b = lines[i].substr(8, 3)
		index += 1
		
		
		add_colour_rect_multi(Color(int(r) / 255.0, int(g) / 255.0, int(b) / 255.0, 1.0), index)
	
	
	
	global.history.add_do_method(self, "build_texture")
	global.history.add_undo_method(self, "build_texture")
	global.history.commit_action()

func save_palette(path):
	var colours = []
	for i in palette_ui.get_children():
		if i is ColorRect:
			colours.push_back(i.color)
	if colours.size() == 0:
		InfoDialog.show_info("Error: Palette is empty!")
		return 
		
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err != 0:
		InfoDialog.show("There was an error opening the file! Error Number: " + str(err))
	file.store_line("JASC-PAL")
	file.store_line("0100")
	file.store_line(str(colours.size()))
	for i in colours:
		var red_pad = "   ".substr(len(str(clamp(int(i.r * 255), 0, 255))), 3)
		var green_pad = "   ".substr(len(str(clamp(int(i.g * 255), 0, 255))), 3)
		var blue_pad = "   ".substr(len(str(clamp(int(i.b * 255), 0, 255))), 3)
		file.store_line(red_pad + str(clamp(int(i.r * 255), 0, 255)) + " " + green_pad + str(clamp(int(i.g * 255), 0, 255)) + " " + blue_pad + str(clamp(int(i.b * 255), 0, 255)))
	file.close()
	
	pass

func _on_LoadButton_pressed():
	file_diag.popup_centered()
	file_diag.mode = FileDialog.MODE_OPEN_FILE
	pass


func _on_SaveButton_pressed():
	file_diag.popup_centered()
	file_diag.mode = FileDialog.MODE_SAVE_FILE
	pass


func _on_FileDialog_file_selected(path):
	if file_diag.mode == FileDialog.MODE_OPEN_FILE:
		load_palette(path)
	elif file_diag.mode == FileDialog.MODE_SAVE_FILE:
		save_palette(path)
		load_presets()
	pass

func _on_DitherSlider_value_changing(value):
	$Viewport / TextureRect.material.set_shader_param("dither_amount", value)
	pass


func _on_AlphaSlider_value_changing(value):
	$Viewport / TextureRect.material.set_shader_param("alpha_threshold", value)
	pass
	
func load_presets():
	$HBoxContainer / Presets.clear()
	$HBoxContainer / Presets.add_item("Select...", 0)
	var dir = Directory.new()
	dir.open(dir_path)
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		$HBoxContainer / Presets.add_item(file)
	pass


func _on_Presets_item_selected(ID):
	if ID != 0:
		load_palette(dir_path + $HBoxContainer / Presets.get_item_text(ID))
	pass
