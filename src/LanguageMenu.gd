extends MenuButton

signal lang_updated
var languages = {"en":"KEY_ENGLISH", "fr":"KEY_FRENCH", "de":"KEY_GERMAN", "it":"KEY_ITALIAN", "es":"KEY_SPANISH", "pt":"KEY_PORTUGUESE"}
var lang_file = {"en":preload("res://languages/translation.en.translation"), "fr":preload("res://languages/translation.fr.translation"), "de":preload("res://languages/translation.de.translation"), "it":preload("res://languages/translation.it.translation"), "es":preload("res://languages/translation.es.translation"), "pt":preload("res://languages/translation.pt.translation")}

func _ready():
	var popup = get_popup()
	for i in languages:
		popup.add_item(languages[i])
	for k in languages.keys():
		TranslationServer.add_translation(lang_file[k])
	
	popup.connect("index_pressed", self, "set_lang")
#	generate_csv()


func set_lang(index):
	TranslationServer.set_locale(languages.keys()[index])
	print(languages.keys()[index])
	return
	emit_signal("lang_updated")
	


func generate_csv():
	var keys := File.new()
	if keys.open("res://languages/source_keys.ini", File.READ) == OK:
		var csv := File.new()
		csv.open("res://languages/translation_generated.csv", File.WRITE)
		var head = "keys"
		for k in languages.keys():
			head += ",\"%s\"" % k
		csv.store_line(head)

		var exist_keys := []

		while keys.get_position() < keys.get_len():
			var line = keys.get_line()
			if line.empty():
				continue
			if exist_keys.has(line):
				continue
			var trans = tr(line)
			if trans == line:
				continue

			var key = line
			for k in languages.keys():

				key += ",\"%s\"" % (lang_file[k] as PHashTranslation).get_message(line)
			csv.store_line(key)
			exist_keys.append(line)
		csv.close()
		keys.close()
