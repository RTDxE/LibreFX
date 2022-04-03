extends Control




signal reset_camera
signal undo
signal redo
var test = preload("res://textures/pentagon.png")
var file_dialog
var clear_project = false

var history_label
var edit_menu

func _ready():
	OS.low_processor_usage_mode = true
	file_dialog = find_node("SaveLoadDialog")
	file_dialog.filters = ["*.bfx"]
	find_node("MenuButton").get_popup().connect("index_pressed", self, "menu_item_selected")
	find_node("ViewButton").get_popup().connect("index_pressed", self, "view_item_selected")
	find_node("EditButton").get_popup().connect("index_pressed", self, "edit_item_selected")
	find_node("HelpButton").get_popup().connect("index_pressed", self, "help_item_selected")
	history_label = find_node("History")
	edit_menu = find_node("EditButton").get_popup()
	
	edit_menu.set_item_disabled(0, true)
	edit_menu.set_item_disabled(1, true)
	OS.center_window()
	pass


func _process(delta):
	if Input.is_action_just_pressed("screenshot"):
		global.save_screenshot()
	if global.history.has_undo():
		edit_menu.set_item_disabled(0, false)
		
	else :
		edit_menu.set_item_disabled(0, true)
		
		
	if global.history.has_redo():
		edit_menu.set_item_disabled(1, false)
		
	else :
		
		edit_menu.set_item_disabled(1, true)
		
		
	if Input.is_action_just_pressed("undo"):
		undo()
			
	if Input.is_action_just_pressed("redo"):
		redo()
			
	$Panel / VBoxContainer / MenuBar / HBoxContainer / MarginContainer / HBoxContainer / FPS.text = str(Engine.get_frames_per_second()) + " FPS"
	var p_count = 0
	
		
	
	

func undo():
	if global.history.get_current_action_index() > - 1:
		history_label.show_message("Undo: " + global.history.get_current_action_name())
		global.history.undo()
	else :
		history_label.show_message("Nothing to undo")
		
func redo():
	if global.history.get_current_action_index() < global.history.get_history_size() - 1:
		global.history.redo()
		history_label.show_message("Redo: " + global.history.get_current_action_name())
	else :
		history_label.show_message("Nothing to redo")

func menu_item_selected(id):
	match (id):
		0:
			new_project()
		2:
			save_project()
		3:
			load_project()
		4:
			import_project()
		6:
			get_tree().quit()
	pass


func view_item_selected(id):
	match (id):
		0:
			
			find_node("ViewportContainer").choose_bg_color()
			pass
		1:
			
			find_node("ViewportContainer").load_bg()
			pass
		2:
			
			find_node("ViewportContainer").clear_bg()
			pass
		4:
			
			emit_signal("reset_camera")
			pass

func edit_item_selected(id):
	match (id):
		0:
			undo()
		1:
			redo()

func help_item_selected(id):
	match (id):
		0:
			OS.shell_open("https://benhickling.itch.io/blastfx-documentation")

func new_project():
	global.history.clear_history()
	find_node("Particle_Editor").clear_emitters()
	find_node("Effects").clear_nodes()
	find_node("ViewportContainer").reset_view()
	find_node("PreviewAnim").clear()
	global.p_count = 0
	pass
	
func save_project():
	file_dialog.popup_centered()
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	
func load_project():
	clear_project = true
	file_dialog.popup_centered()
	file_dialog.mode = FileDialog.MODE_OPEN_FILE

func import_project():
	clear_project = false
	file_dialog.popup_centered()
	file_dialog.mode = FileDialog.MODE_OPEN_FILE

func _on_FileDialog_file_selected(path):
	match (file_dialog.mode):
		FileDialog.MODE_SAVE_FILE:
			var data = find_node("Particle_Editor").get_project_json(path.get_base_dir())
			var file = File.new()
			var err = file.open(path, File.WRITE)
			if err != 0:
				InfoDialog.show_info("Error: Unable to save project file!")
				return 
			file.store_line(data)
			file.close()
		
		FileDialog.MODE_OPEN_FILE:
			var file = File.new()
			var err = file.open(path, File.READ)
			if err != 0:
				InfoDialog.show_info("Error: Unable to open project file!")
				return 
			var file_data = parse_json(file.get_line())
			file.close()
			if not file_data:
				InfoDialog.show_info("Error: Invalid project file!")
				return 
			if clear_project:
				new_project()
			
				
			yield (get_tree(), "idle_frame")
			find_node("Particle_Editor").load_project_json(path.get_base_dir(), file_data, not clear_project)
			global.p_count = 0
			if clear_project:
				global.history.clear_history()
	pass


