extends GridContainer

signal value_changed
signal type_changed
signal vector_type_changed

var property_button = preload("res://PropertyButton.tscn")
var value_edit_scene = preload("res://ValueEdit.tscn")
var vector_edit_scene = preload("res://VectorEdit.tscn")
var color_edit_scene = preload("res://ColorEdit.tscn")
var image_edit_scene = preload("res://ImageEdit.tscn")
var option_edit_scene = preload("res://OptionEdit.tscn")
var check_edit_scene = preload("res://CheckEdit.tscn")
var pivot_edit_scene = preload("res://PivotEdit.tscn")
var current_emitter
var gui = {}
var needs_populating = true


func _ready():
	pass






func create_properties():
	if not needs_populating:
		update_properties()
		return 
	needs_populating = false
	
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
			
	var property_keys = emitter.properties
	for properties in property_keys:
		var button = property_button.instance()
		var grid = VBoxContainer.new()
		button.grid = grid
		button.set_text(properties)
		grid.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(button)
		add_child(grid)
		
		grid.visible = false
		for i in property_keys[properties]:
			var curve_default = Vector2(0.0, 1.0)
			if property_keys[properties][i].has("curve_default"):
				curve_default = property_keys[properties][i]["curve_default"]
			
			match (property_keys[properties][i]["type"]):
				emitter.VALUE_TYPE.NUMERIC:
					numeric_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i, property_keys[properties][i]["min"], property_keys[properties][i]["max"], true)
				emitter.VALUE_TYPE.NUMERIC_SINGLE:
					numeric_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i, property_keys[properties][i]["min"], property_keys[properties][i]["max"], false, curve_default)
				emitter.VALUE_TYPE.VECTOR:
					vector_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i, property_keys[properties][i]["min"], property_keys[properties][i]["max"], true)
				emitter.VALUE_TYPE.VECTOR_NO_RANGE:
					vector_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i, property_keys[properties][i]["min"], property_keys[properties][i]["max"], false)
				emitter.VALUE_TYPE.COLOR:
					colour_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i)
				emitter.VALUE_TYPE.IMAGE:
					image_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i)
				emitter.VALUE_TYPE.BOOL:
					bool_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i)
				emitter.VALUE_TYPE.OPTION:
					option_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i, property_keys[properties][i]["items"], property_keys[properties][i]["callback"])
				emitter.VALUE_TYPE.PIVOT:
					pivot_field(true, property_keys[properties][i]["name"], property_keys[properties][i]["hint"], grid, i)
	
	emitter.shape_changed(null, emitter.emitter_shape)
	emitter.motion_changed(null, emitter.motion_type)
	
func update_properties(index = null):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
			
	var property_keys = emitter.properties
	if not index:
		for properties in property_keys:
			for i in property_keys[properties]:
				update_property(emitter, property_keys, properties, i)
	else :
		var key = find_prop_key(property_keys, index)
		update_property(emitter, property_keys, key, index)
		
	emitter.shape_changed(null, emitter.emitter_shape)
	emitter.motion_changed(null, emitter.motion_type)


func find_prop_key(keys, index):
	for i in keys:
		if keys[i].has(index):
			return i

func update_property(emitter, dict, properties, i):
	var curve_default = Vector2(0.0, 1.0)
	if dict[properties][i].has("curve_default"):
		curve_default = dict[properties][i]["curve_default"]
		
	match (dict[properties][i]["type"]):
		emitter.VALUE_TYPE.NUMERIC:
			numeric_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i, dict[properties][i]["min"], dict[properties][i]["max"], true)
		emitter.VALUE_TYPE.NUMERIC_SINGLE:
			numeric_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i, dict[properties][i]["min"], dict[properties][i]["max"], false, curve_default)
		emitter.VALUE_TYPE.VECTOR:
			vector_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i, dict[properties][i]["min"], dict[properties][i]["max"], true)
		emitter.VALUE_TYPE.VECTOR_NO_RANGE:
			vector_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i, dict[properties][i]["min"], dict[properties][i]["max"], false)
		emitter.VALUE_TYPE.COLOR:
			colour_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i)
		emitter.VALUE_TYPE.IMAGE:
			image_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i)
		emitter.VALUE_TYPE.BOOL:
			bool_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i)
		emitter.VALUE_TYPE.OPTION:
			option_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i, dict[properties][i]["items"], dict[properties][i]["callback"])
		emitter.VALUE_TYPE.PIVOT:
			pivot_field(false, dict[properties][i]["name"], dict[properties][i]["hint"], null, i)
	pass

func numeric_field(create, title, tip, grid, index, _min, _max, use_range, curve_default_range = Vector2(0.0, 1.0)):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	var field
	if create:
		field = value_edit_scene.instance()
		gui[index] = field
		emitter.gui[index] = field
		grid.add_child(field)
		field.set_name(index)
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.connect("value_type_changed", self, "type_changed")
		field.connect("value_changed", self, "value_changed")
	else :
		field = gui[index]
		emitter.gui[index] = field
		field.set_label(tr(title))
		field.set_tip(tr(tip))
	var prop = emitter.get_prop(index)
	field.ready = false

	match (typeof(prop)):
		TYPE_INT:
			field.set_value_range(_min, _max)
			field.set_value(prop)
			field.set_value_type(0)
		TYPE_REAL:
			field.set_value_range(_min, _max)
			field.set_value(prop)
			field.set_value_type(0)
		TYPE_VECTOR2:
			field.set_value_range(_min, _max)
			field.set_vector_value(prop)
			field.set_value_type(1)
		TYPE_NIL:
			print(index + " is uninitialized!")
			assert (false)
		_:
			field.set_curve(prop)
			field.set_value_type(2)
			if create:
				field.set_value_range(_min, _max)
				field.set_curve_min_max(curve_default_range.x, curve_default_range.y)
			field.refresh()
	field.set_use_range(use_range)
	field.ready = true


func vector_field(create, title, tip, grid, index, _min, _max, use_range):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	var field
	if create:
		field = vector_edit_scene.instance()
		gui[index] = field
		emitter.gui[index] = field
		grid.add_child(field)
		field.set_name(index)
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.connect("value_type_changed", self, "vector_type_changed")
		field.connect("value_changed", self, "value_changed")
	else :
		field = gui[index]
		emitter.gui[index] = field
		field.set_label(tr(title))
		field.set_tip(tr(tip))
	var prop = emitter.get_prop(index)
	field.ready = false
	
	match (typeof(prop)):
		TYPE_VECTOR2:
			field.set_min_value(_min)
			field.set_max_value(_max)
			field.set_vector(prop)
			field.set_value_type(0)
		TYPE_RECT2:
			field.set_min_value(_min)
			field.set_max_value(_max)
			field.set_rect(prop)
			field.set_value_type(1)
	field.set_use_range(use_range)
	field.ready = true

func colour_field(create, title, tip, grid, index):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	var field
	if create:
		field = color_edit_scene.instance()
		gui[index] = field
		emitter.gui[index] = field
		
		grid.add_child(field)
		field.set_name(index)
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.connect("value_changed", self, "value_changed")
	else :
		field = gui[index]
		emitter.gui[index] = field
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		
	var prop = emitter.get_prop(index)
	field.set_gradient(prop)


func image_field(create, title, tip, grid, index):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
		
	var field
	if create:
		field = image_edit_scene.instance()
		gui[index] = field
		emitter.gui[index] = field
		
		grid.add_child(field)
		field.set_name(index)
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.connect("value_changed", self, "value_changed")
	else :
		field = gui[index]
		emitter.gui[index] = field
		field.set_label(tr(title))
		field.set_tip(tr(tip))

	var prop = emitter.get_prop(index)
	field.set_image(prop)
	if gui.has("offset") and index == "tex":
		gui["offset"].set_image(prop)

	
func bool_field(create, title, tip, grid, index):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	var field
	if create:
		field = check_edit_scene.instance()
		gui[index] = field
		emitter.gui[index] = field
		grid.add_child(field)
		field.set_name(index)
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.connect("value_changed", self, "value_changed")
	else :
		field = gui[index]
		emitter.gui[index] = field
		field.set_label(tr(title))
		field.set_tip(tr(tip))

	var prop = emitter.get_prop(index)
	field.ready = false
	field.set_value(prop)
	field.ready = true

	
func option_field(create, title, tip, grid, index, items, callback):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
	var field
	if create:
		field = option_edit_scene.instance()
		grid.add_child(field)
		field.set_name(index)
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.connect("value_changed", self, "value_changed", [callback])
		gui[index] = field
		emitter.gui[index] = field
	else :
		field = gui[index]
		emitter.gui[index] = field
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.clear_items()
	var prop = emitter.get_prop(index)
	field.ready = false
	
	for i in items:
		field.add_item(i)
	field.select(prop)
	field.ready = true
	
func pivot_field(create, title, tip, grid, index):
	var emitter = current_emitter.get_ref()
	if not emitter:
		return 
		
	var field
	if create:
		field = pivot_edit_scene.instance()
		gui[index] = field
		emitter.gui[index] = field
		
		grid.add_child(field)
		field.set_name(index)
		field.set_label(tr(title))
		field.set_tip(tr(tip))
		field.connect("value_changed", self, "value_changed")
	else :
		field = gui[index]
		emitter.gui[index] = field
		field.set_label(tr(title))
		field.set_tip(tr(tip))

	var prop = emitter.get_prop(index)
	field.set_image(emitter.get_prop("tex"))
	field.set_pivot(prop)

func _on_Particle_Editor_emitter_changed(emitter):
	current_emitter = emitter
	create_properties()
	
	pass

func value_changed(prop, value, callback = ""):
	if callback:
		emit_signal("value_changed", prop, value, callback)
	else :
		emit_signal("value_changed", prop, value)
	pass
	
func type_changed(prop, type, control):
	emit_signal("type_changed", prop, type, control)
	pass
	
func vector_type_changed(prop, type, control):
	emit_signal("vector_type_changed", prop, type, control)
	pass



func _on_Particle_Editor_enable_properties(enable):
	for i in get_children():
		if i is Button:
			i.grid.visible = i.grid.visible and enable
			i.disabled = not enable
	pass


func _on_Particle_Editor_emitter_value_changed(prop, value):
	update_properties(prop)
	pass
