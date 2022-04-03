extends Label




var tween = Tween.new()

func _ready():
	add_child(tween)
	
	pass





func show_message(msg):
	text = msg
	self_modulate = Color(1, 1, 1, 1)
	tween.stop_all()
	tween.interpolate_property(self, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	tween.start()
	pass
