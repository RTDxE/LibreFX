extends Camera2D





var pan = Vector2()
var old_pos = Vector2()

func _ready():
	pass






func _on_zoom_changed(z):
	zoom = Vector2(z, z)
	pass


func _on_pan_changed(p):
	pan = p
	position = old_pos + p
	pass


func _on_pan_finished():
	old_pos = position
	pass


func _on_reset_camera():
	zoom = Vector2(1.0, 1.0)
	position = Vector2(0, 0)
	old_pos = position
	pass
	
func get_dict():
	var dict = {}
	dict["position"] = global.vec_to_dict(position)
	dict["zoom"] = global.vec_to_dict(zoom)
	dict["pan"] = global.vec_to_dict(pan)
	return dict

func _on_Particle_Editor_camera_setup(pos, z, p):
	pan = p
	old_pos = pos
	position = pos
	zoom = z
	pass
