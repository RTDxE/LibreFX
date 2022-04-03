extends Control




signal value_changed
var prop_name = ""
var image
var orig_size = Vector2()

func _ready():
	pass





func set_name(n):
	prop_name = n
	
func set_label(text):
	$HBoxContainer / Label.text = text
	
func set_tip(tip):
	hint_tooltip = tip
	
func set_pivot(value):
	$HBoxContainer / PanelContainer / Image.pivot = value / (orig_size / 2.0)
	
func get_pivot():
	return $HBoxContainer / Image.pivot
	
func set_image(value):
	image = value
	var texture = image.get_data()
	orig_size = image.get_size()
	texture.resize(64, 64, Image.INTERPOLATE_BILINEAR)
	var new_tex = ImageTexture.new()
	new_tex.create_from_image(texture)
	new_tex.flags = image.flags
	$HBoxContainer / PanelContainer / Image.texture = new_tex

func _on_Image_pivot_changed(value):
	emit_signal("value_changed", prop_name, value * (orig_size / 2.0))
	pass
