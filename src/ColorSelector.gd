extends WindowDialog






func _ready():
	$ColorPicker.raw_mode = false
	pass






func _on_ColorSelector_popup_hide():
	var connections = $ColorPicker.get_signal_connection_list("color_changed")
	for i in connections:
		$ColorPicker.disconnect("color_changed", i["target"], i["method"])
	pass
