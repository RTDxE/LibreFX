extends TabContainer






func _ready():
	translate_tabs()





func _on_LanguageMenu_lang_updated():
	translate_tabs()
	pass


func translate_tabs():
	var children = get_children()
	for i in range(children.size()):
		set_tab_title(i, tr(children[i].title))
