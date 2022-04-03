extends WindowDialog




var gradient_button_script = preload("res://GradientButton.gd")
var gradients_path
export (NodePath) var gradient_nodepath
var gradient_node

func _ready():
	gradients_path = global.res_path + "gradients/"
	gradient_node = get_node(gradient_nodepath)
	$FileDialog.filters = ["*.gra"]
	$FileDialog.current_path = gradients_path
	update_list()
	pass





func update_list():
	var box = $MarginContainer / VBoxContainer / ScrollContainer / VBoxContainer
	var dir = Directory.new()
	var err = dir.open(gradients_path)
	if err != 0:
		InfoDialog.show_info("Error: Unable to open gradient preset directory: " + gradients_path)
		return 
	dir.list_dir_begin(true, true)
	clear_list()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if file.get_extension() == "gra":
			var json = load_gradient(file)
			var gradient = global.dict_to_gradient(json)
			var container = HBoxContainer.new()
			box.add_child(container)
			var button = Button.new()
			button.rect_min_size = Vector2(200, 16)
			button.set_script(gradient_button_script)
			button.text = file
			button.texture = GradientTexture.new()
			button.texture.gradient = gradient

			button.connect("button_down", self, "apply_gradient", [file])
			container.add_child(button)
			
			var del_button = Button.new()
			del_button.text = " X "
			del_button.connect("pressed", self, "remove_gradient", [file])
			container.add_child(del_button)

func load_gradient(path):
	var file = File.new()
	file.open(gradients_path + path, File.READ)
	var data = file.get_line()
	if not data:
		InfoDialog.show_info("Error: No gradient data found!")
		return 
	var json = parse_json(data)
	file.close()
	return json


func apply_gradient(path):
	var json = load_gradient(path)
	var gradient = gradient_node.gradient
	for i in range(0, gradient.get_point_count() - 2):
		if i < 3:
			gradient.remove_point(i)

	
		
	
	gradient.set_offset(0, float(json.keys()[0]))
	gradient.set_color(0, global.dict_to_color(json.values()[0]))
	gradient.set_offset(1, float(json.keys()[json.size() - 1]))
	gradient.set_color(1, global.dict_to_color(json.values()[json.size() - 1]))
	if json.size() >= gradient.get_point_count():
		for i in range(1, json.size() - 1):
			gradient.add_point(float(json.keys()[i]), global.dict_to_color(json.values()[i]))
			
		
			
	gradient_node.update()
	
	
		


func remove_gradient(path):
	var dir = Directory.new()
	var err = dir.open(gradients_path)
	if err != 0:
		InfoDialog.show_info("Error: Unable to open gradient preset directory")
	err = dir.remove(path)
	if err != 0:
		InfoDialog.show_info("Error: Unable to delete gradient file: " + path)
	update_list()


func clear_list():
	for i in $MarginContainer / VBoxContainer / ScrollContainer / VBoxContainer.get_children():
		i.queue_free()

func show_presets():
	popup_centered()
	update_list()
	pass


func _on_FileDialog_file_selected(path):
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err != 0:
		InfoDialog.show_info("Error: Unable to open file for writing!")
		return 
	file.store_line(to_json(global.gradient_to_dict(gradient_node.gradient)))
	file.close()
	update_list()
	pass


func save_gradient():
	$FileDialog.popup_centered()
	$FileDialog.invalidate()
	pass
