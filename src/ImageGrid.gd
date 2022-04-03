extends WindowDialog




signal image_selected
signal done_loading
var thread = Thread.new()
var mutex = Mutex.new()
var image_grid
var folder_grid
var button
var path
var first_time = true
var window_active = false
var folder_icon = preload("res://folder.png")
var back_icon = preload("res://back_arrow.png")

var files = []
var folders = []


func _ready():
	path = global.res_path + "textures/"
	
	$FileDialog.current_dir = path
	$FileDialog.current_path = path
	image_grid = find_node("Images")
	folder_grid = find_node("Folders")
	button = find_node("Button")
	$FileDialog.filters = [" "]
	
	
	
	pass





func show_list():
	window_active = true
	popup_centered()
	if first_time:
		first_time = false
		if not thread.is_active():
			thread.start(self, "list_images", path)

			
func update_list(image_dir):
	if not thread.is_active():
		clear_grid()
		yield (get_tree(), "idle_frame")
		$MarginContainer / HBoxContainer / VBoxContainer / ScrollContainer / Loading.text = "Loading..."
		$MarginContainer / HBoxContainer / VBoxContainer / ScrollContainer / Loading.visible = true
		yield (get_tree(), "idle_frame")
		thread.start(self, "list_images", image_dir)

func list_images(image_dir):

	var dir = Directory.new()
	var dir_err = dir.open(image_dir)
	if dir_err != 0:
		call_deferred("thread_done")
		return false
	
	if dir_err == 0:
		dir.list_dir_begin(false, true)
		var loop = window_active
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				if file.ends_with(".png"):
					mutex.lock()
					files.append(image_dir + file)
					mutex.unlock()
			if dir.current_is_dir() and file != ".":
				mutex.lock()
				folders.append(image_dir + file)
				mutex.unlock()
				
		

	call_deferred("thread_done")
	return true


func clear_grid():
	files = []
	folders = []
	for i in image_grid.get_children():
		i.queue_free()
	for i in folder_grid.get_children():
		i.queue_free()
		
func populate_grid():
	for f in folders:
		var preview = Button.new()
		preview.rect_min_size = Vector2(64, 64)
		preview.icon = folder_icon
		preview.align = Button.ALIGN_CENTER
		
		if f.get_file() != "..":
			var text = f.get_file()
			if len(text) > 16:
				text = text.substr(0, 16) + "..."
			preview.text = text
			preview.icon = folder_icon
		else :
			preview.icon = back_icon
			preview.text = "Back"
		preview.connect("pressed", self, "update_list", [f + "/"])
		folder_grid.add_child(preview)
			
	for file in files:
		var preview = Button.new()
		preview.align = Button.ALIGN_CENTER
		var image = Image.new()
		var err = image.load(file)
		if err != 0:
			continue
		image.resize(64, 64)
		var tex = ImageTexture.new()
		tex.create_from_image(image)
		preview.icon = tex
		preview.connect("pressed", self, "selected", [file])
		image_grid.add_child(preview)
		
	yield (get_tree(), "idle_frame")
	if files.size() < 1:
		$MarginContainer / HBoxContainer / VBoxContainer / ScrollContainer / Loading.text = "No PNG images found"
	else :
		$MarginContainer / HBoxContainer / VBoxContainer / ScrollContainer / Loading.visible = false
	
	pass

func thread_done():
	var result = thread.wait_to_finish()
	emit_signal("done_loading")
	populate_grid()
	

func load_image(path):
	pass
	
func selected(path):
	emit_signal("image_selected", path)
	hide()
	
	
	
	


func _on_Button_pressed():
	$FileDialog.popup_centered()
	pass


func _on_FileDialog_dir_selected(dir):
	dir = dir + "/"
	update_list(dir)
	pass


func _on_ImageGrid_done_loading():
	yield (get_tree(), "idle_frame")
	button.disabled = false
	pass


func _on_ImageGrid_popup_hide():
	hide()
	window_active = false
	pass
