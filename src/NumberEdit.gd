extends LineEdit




export (float) var min_value = 0.0
export (float) var max_value = 1.0

func _ready():
	pass






func _on_NumberEdit_text_changed(new_text):
	text = str(clamp(float(new_text), min_value, max_value)).pad_decimals(1)
	caret_position = 10
	pass
