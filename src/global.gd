extends Node




var texture_size = Vector2(512, 512)
var render_size = Vector2(256, 256)
var max_frames_per_row = 16384.0
var frame_amount = 60
var render_fps = 60.0
var render_wait = 0
var p_count = 0
var checker = preload("checker.png")
var checker8 = preload("checker_8.png")
var default_tex = preload("res://textures/soft_circle_64.png")
var default_flow = preload("res://textures/flow_maps/no_flow.png")

var font = preload("res://Fonts/main_font.tres")
var shot_index = 0
var emitters = []
var history = UndoRedo.new()

var bg_image = Image.new()
var bg_pos = Vector2()
var bg_tex = ImageTexture.new()
var bg_color = Color(0, 0, 0, 1)
var transformed_bg_rect
var show_bg_color = false
var show_bg_tex = false

var res_path



func _ready():
	if OS.get_name() == "OSX":
		res_path = OS.get_executable_path().get_base_dir() + "/../Resources/"
	else :
		res_path = OS.get_executable_path().get_base_dir() + "/"
	font.size = 18
	
	pass

func emitters_add(index, e):
	global.emitters.insert(index, weakref(e))

func emitters_remove(index):
	global.emitters.remove(index)
	
func emitters_pushback(e):
	global.emitters.push_back(e)
	
func emitters_remove_last():
	global.emitters.pop_back()

func convert_to_relative(base, path):
	print("base: " + base)
	print("path: " + path)
	var first = path.find(base)
	if first > - 1:
		var sub = path.substr(first + len(base), len(path) - first)
		print(sub)
		return sub
	else :
		var file = path.get_file()
		var index = path.find(file)
		var no_start = path.substr(path.find("/") + 1, len(path))
		var split = base.split("/")
		var new_path = ""
		for i in range(1, len(split) - 1):
			print(i)
			new_path += "../"
		print(new_path + no_start)
		return new_path + no_start
	pass

func save_screenshot():
	shot_index += 1
	var data = get_viewport().get_texture().get_data()
	data.flip_y()
	data.save_png("c:/screenshot" + str(shot_index) + ".png")

func new_curve(start, end):
	var curve = Curve.new()
	curve.add_point(start)
	curve.add_point(end)
	curve.bake_resolution = 512
	return curve

func load_texture(path, filtered = true, relative = false, base_dir = ""):
	print(path)
	var tex = ImageTexture.new()
	var image = Image.new()
	var file = File.new()
	var err = 0
	if path.find("no_flow.png") > - 1:
		return default_flow
	if relative:
		var base = base_dir
		path = base.plus_file(path)
		
	if file.file_exists(path):
		err = image.load(path)
		if err != 0:
			print("Error loading image")
			return default_tex
	else :
		
		return default_tex
	tex.create_from_image(image)
	tex.flags = 0 if not filtered else 4
	tex.set_meta("path", path)
	tex.set_meta("filtered", tex.flags)
	return tex

func dict_to_curve(d):
	var curve = Curve.new()
	var dict = d["value"]
	for i in dict:
		var pos = Vector2(dict[i]["pos"]["x"], dict[i]["pos"]["y"])
		curve.add_point(pos, dict[i]["left_tangent"], dict[i]["right_tangent"], dict[i]["left_mode"], dict[i]["right_mode"])
	curve.min_value = d["min"]
	curve.max_value = d["max"]
	return curve

func dict_to_gradient(dict):
	var gradient = Gradient.new()
	while gradient.get_point_count() < dict.size():
		gradient.add_point(0, Color(1, 1, 1, 1))
		
	for i in range(0, dict.size()):
		gradient.set_offset(i, float(dict.keys()[i]))
		gradient.set_color(i, dict_to_color(dict.values()[i]))
	return gradient
	
func dict_to_color(dict):
	return Color(dict["r"], dict["g"], dict["b"], dict["a"])

func dict_to_vec(dict):
	return Vector2(dict["x"], dict["y"])
	
func dict_to_rect(dict):
	return Rect2(dict["x"], dict["y"], dict["w"], dict["h"])
	

func vec_to_dict(vec):
	var dict = {}
	dict["x"] = vec.x
	dict["y"] = vec.y
	return dict
	
func rect_to_dict(rect):
	var dict = {}
	dict["x"] = rect.position.x
	dict["y"] = rect.position.y
	dict["w"] = rect.size.x
	dict["h"] = rect.size.y
	return dict

func gradient_to_dict(grad):
	var dict = {}
	for i in range(0, grad.colors.size()):
		dict[grad.offsets[i]] = color_to_dict(grad.colors[i])
	return dict
	
func curve_to_dict(curve):
	var dict = {}
	for i in range(0, curve.get_point_count()):
		dict[i] = {"pos":vec_to_dict(curve.get_point_position(i)), 
					"left_mode":curve.get_point_left_mode(i), 
					"left_tangent":curve.get_point_left_tangent(i), 
					"right_mode":curve.get_point_right_mode(i), 
					"right_tangent":curve.get_point_right_tangent(i)}
	return dict
	
func color_to_dict(col):
	var dict = {}
	dict["r"] = col.r
	dict["g"] = col.g
	dict["b"] = col.b
	dict["a"] = col.a
	return dict
	
func try_key(dict, key):
	if dict.has(key):
		return dict[key]
	else :
		print(key + " property missing from project, skipping")
		return {}

func try_value(dict, key, fail):
	if dict.has(key):
		return dict[key]
	else :
		return fail
