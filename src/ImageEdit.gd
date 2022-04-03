extends Control




signal value_changed
var image
var prop_name = ""
var current_file = ""
var path = ""

func _ready():
	$CanvasLayer / FileDialog.filters = ["*.png"]
	$CanvasLayer / FileDialog.access = FileDialog.ACCESS_FILESYSTEM
	$CanvasLayer / FileDialog.set_as_toplevel(true)
	$CanvasLayer / FileDialog.set("z", - 4095)
	pass





func set_name(n):
	prop_name = n
	
func set_label(text):
	$MarginContainer / HBoxContainer / Label.text = text
	
func set_tip(tip):
	$MarginContainer.hint_tooltip = tip

func _on_ToolButton_pressed():
	
	$CanvasLayer / ImageGrid.show_list()
	pass


func _on_FileDialog_file_selected(path):
	load_texture(path)
	pass


func set_image(value):
	image = value
	var texture = image.get_data()
	if not texture:
		return 
	texture.resize(64, 64, Image.INTERPOLATE_BILINEAR)
	var new_tex = ImageTexture.new()
	new_tex.create_from_image(texture)
	new_tex.flags = image.flags
	$MarginContainer / HBoxContainer / ImageButton.icon = new_tex
	$MarginContainer / HBoxContainer / CheckBox.pressed = false if new_tex.flags == 0 else true

func load_texture(path):
	image = global.load_texture(path, $MarginContainer / HBoxContainer / CheckBox.pressed)
	
	
	
	var texture = image.get_data()
	texture.resize(64, 64, Image.INTERPOLATE_BILINEAR)
	var new_tex = ImageTexture.new()
	new_tex.create_from_image(texture)
	$MarginContainer / HBoxContainer / ImageButton.icon = new_tex
	emit_signal("value_changed", prop_name, image)
	pass



func _on_Timer_timeout():
	if current_file != $CanvasLayer / FileDialog.current_path:
		current_file = $CanvasLayer / FileDialog.current_path
		load_preview($CanvasLayer / FileDialog.current_path)
	pass
	
func load_preview(path):
	if path.substr(len(path) - 4, 4) != ".png":
		$CanvasLayer / FileDialog / Preview.texture = null
		$CanvasLayer / FileDialog / Node2D / Label2.hide()
		$CanvasLayer / FileDialog / PreviewBG.hide()
		return 
	var file_check = File.new()
	if not file_check.file_exists(path):
		$CanvasLayer / FileDialog / Preview.texture = null
		$CanvasLayer / FileDialog / Node2D / Label2.hide()
		$CanvasLayer / FileDialog / PreviewBG.hide()
		return 
	var image = ImageTexture.new()
	image.load(path)
	image.set_flags(0)
	if image.get_size().length() > 0:
		var scale = 128.0 / image.get_size().x
		$CanvasLayer / FileDialog / Node2D / Label2.show()
		$CanvasLayer / FileDialog / Preview.texture = image
		$CanvasLayer / FileDialog / Preview.scale = Vector2(scale, scale)
		$CanvasLayer / FileDialog / PreviewBG.show()


func _on_CheckBox_toggled(button_pressed):
	image.set_flags(4 if button_pressed else 0)
	image.set_meta("filtered", button_pressed)
	emit_signal("value_changed", prop_name, image)
	pass


func _on_ImageGrid_image_selected(path):
	load_texture(path)
	pass
