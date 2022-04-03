extends CanvasLayer






func _ready():
	pass





func show_info(message):
	$ColorRect.show()
	
	$AcceptDialog / RichTextLabel.bbcode_text = "[center]" + message + "[/center]"
	$AcceptDialog.popup_centered()

func _on_AcceptDialog_confirmed():
	$ColorRect.hide()
	pass


func _on_RichTextLabel_meta_clicked(meta):
	$AcceptDialog.hide()
	OS.shell_open(meta)
	pass


func _on_AcceptDialog_popup_hide():
	$ColorRect.hide()
	pass
