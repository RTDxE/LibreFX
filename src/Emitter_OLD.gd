extends Node2D



signal update

enum VALUE_TYPE{NUMERIC, NUMERIC_SINGLE, VECTOR, VECTOR_NO_RANGE, COLOR, IMAGE, BOOL, OPTION}
var p_general = {"duration":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":100, "name":"PROP_DURATION"}, 
				"amount":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":1, "max":1000, "name":"PROP_AMOUNT"}, 
				"start_lifetime":{"type":VALUE_TYPE.NUMERIC, "min":0.001, "max":100, "name":"PROP_START_LIFE"}, 
				"start_delay":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":100, "name":"PROP_START_DELAY"}, 
					"start_size":{"type":VALUE_TYPE.NUMERIC, "min": - 100, "max":100, "name":"PROP_START_SIZE"}, 
				"start_angle":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_START_ANGLE"}, 
				"start_speed":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_START_SPEED"}, 
					"gravity":{"type":VALUE_TYPE.VECTOR_NO_RANGE, "min": - 10000, "max":10000, "name":"PROP_GRAVITY"}, 
					"angle":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_ANGLE"}, 
					"spread":{"type":VALUE_TYPE.NUMERIC, "min":0, "max":180, "name":"PROP_SPREAD"}}
					
var p_shape = {"emitter_shape":{"type":VALUE_TYPE.OPTION, "items":["Point", "Box", "Circle"], "callback":"shape_changed", "name":"PROP_SHAPE"}, 
			"emitter_extents":{"type":VALUE_TYPE.VECTOR_NO_RANGE, "min": - 1000, "max":1000, "name":"PROP_SHAPE_EXTENTS"}, 
			"emitter_radius":{"type":VALUE_TYPE.NUMERIC, "min": - 1000, "max":1000, "name":"PROP_SHAPE_RADIUS"}}

var p_velocity = {"velocity_multiplier":{"type":VALUE_TYPE.NUMERIC, "min": - 100, "max":100, "name":"PROP_VELOCITY_MULTIPLIER"}, 
					"orbital_velocity":{"type":VALUE_TYPE.NUMERIC, "min": - 100, "max":100, "name":"PROP_ORBITAL_VELOCITY"}}
					
var p_motion = {"motion_type":{"type":VALUE_TYPE.OPTION, "items":["None", "Sin & Cos", "Path"], "callback":"motion_changed", "name":"PROP_MOTION_TYPE"}, 
				"sin_frequency":{"type":VALUE_TYPE.NUMERIC, "min": - 100, "max":100, "name":"PROP_SIN_FREQ"}, 
				"cos_frequency":{"type":VALUE_TYPE.NUMERIC, "min": - 100, "max":100, "name":"PROP_COS_FREQ"}, 
				"sin_amplitude":{"type":VALUE_TYPE.NUMERIC, "min": - 100, "max":100, "name":"PROP_SIN_AMP"}, 
				"cos_amplitude":{"type":VALUE_TYPE.NUMERIC, "min": - 100, "max":100, "name":"PROP_COS_AMP"}}

var p_image = {"tex":{"type":VALUE_TYPE.IMAGE, "name":"PROP_PARTICLE_TEX"}, 
				"tiles":{"type":VALUE_TYPE.VECTOR_NO_RANGE, "min":1, "max":1024, "name":"PROP_ANIM_TILES"}, 
				"frame_lifetime":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1024, "name":"PROP_FRAME_LIFETIME"}}
				
var p_color = {"lifetime_color":{"type":VALUE_TYPE.COLOR, "name":"PROP_LIFE_COLOR"}}

var p_angle = {"angular_velocity":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 100, "max":100, "name":"PROP_ANGULAR_VELOCITY"}}

var p_size = {"lifetime_size":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 100, "max":100, "name":"PROP_LIFE_SIZE"}}

var properties = {"KEY_GENERAL_PROPERTIES":p_general, "KEY_EMITTER_SHAPE":p_shape, "KEY_PARTICLE_VELOCITY":p_velocity, "KEY_EMITTER_MOTION":p_motion, "KEY_PARTICLE_TEXTURE":p_image, "KEY_PARTICLE_COLOR":p_color, "KEY_PARTICLE_SIZE":p_size, "KEY_PARTICLE_ANGLE":p_angle}

var gui = {}

var emitter_name = "Emitter"
var emitting = true
var tex = preload("res://sparkle.png")
var texture_filtering = bool(tex.flags)
var texture_path = "sparkle.png"
var tiles = Vector2(1, 1)
var frame_lifetime = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var blend_mode = 0
var local = false
var loop = true
var layer = 0
var orig_pos
var time = 0.0
var duration = 5.0
var amount = 60
var accumulator = 0.0
var start_lifetime = 1.0
var start_delay = 0.0
var start_size = 1.0
var start_angle = 0.0
var start_speed = 10.0
var lifetime_color = Gradient.new()
var velocity_multiplier = global.new_curve(Vector2(0, 1), Vector2(1, 1))
var orbital_velocity = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var angular_velocity = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var lifetime_size = global.new_curve(Vector2(0, 1), Vector2(1, 1))
var gravity = Vector2(0, 98.0)
var angle = 0.0
var spread = 0.0
var emitter_shape = 0
var emitter_extents = Vector2(100, 100)
var emitter_radius = 50.0
var motion_type = 0
var sincos_ang = 0.0
var sin_frequency = 1.0
var cos_frequency = 1.0
var sin_amplitude = 10.0
var cos_amplitude = 10.0
var p_scene = preload("res://Particle.tscn")


var temp_z = 0
var wait_time = 0.0

func _ready():
	orig_pos = position
	lifetime_color.set_color(0, Color(1, 1, 1, 1))
	lifetime_color.set_color(1, Color(1, 1, 1, 1))
	material = material.duplicate()
	pass
	
func _physics_process(delta):
	if emitting:
		process_emitter(delta)


func process_emitter(delta):
	z_index = layer
	var dur = get_value(duration)
	if loop:
		time = wrapf(time + delta, 0.0, duration + start_delay)
	else :
		time += delta
	
	
	if time <= (duration + start_delay) and time > start_delay:
		generate_particles(delta)
		
		
			
			
			
	if motion_type == 1:
		sincos_ang += 1 * delta
		position = orig_pos + Vector2(sin(sincos_ang * get_value(sin_frequency)) * get_value(sin_amplitude), cos(sincos_ang * get_value(cos_frequency)) * get_value(cos_amplitude))

	emit_signal("update", delta)

func burst():
	accumulator = 1.0

func generate_particles(delta):
	accumulator += delta
	while (accumulator > 1.0 / amount):
		spawn()
		accumulator -= (1.0 / amount)

func get_prop(prop):
	return get(prop)
	
func set_prop(prop, value):
	set(prop, value)

func start():
	emitting = true
	time = 0.0

func stop():
	clear_particles()
	emitting = false

func spawn():
	temp_z = wrapi(z_index + 1, z_index, z_index + 200)
	var p = p_scene.instance()
	connect("update", p, "process")
	p.material = material
	p.material.blend_mode = blend_mode
	p.texture = tex
	p.hframes = tiles.x
	p.vframes = tiles.y
	p.frame_lifetime = frame_lifetime
	p.emitter = self
	p.lifetime = get_value(start_lifetime)
	p.size = get_value(start_size)
	p.size_curve = lifetime_size
	p.start_pos = position
	p.rotation_degrees = get_value(start_angle)
	p.angular_velocity = angular_velocity
	p.velocity_multiplier = velocity_multiplier
	p.orbital_velocity = orbital_velocity
	var ang_range = rand_range( - get_value(spread), get_value(spread))
	p.velocity = Vector2(0, - get_value(start_speed)).rotated(deg2rad(get_value(angle) + ang_range))
	p.gradient = lifetime_color
	p.z_index = clamp(temp_z, 0, 4095)
	
	p.position = position
	if emitter_shape == 1:
		p.position += Vector2(rand_range( - emitter_extents.x, emitter_extents.x), rand_range( - emitter_extents.y, emitter_extents.y))
	elif emitter_shape == 2:
		p.position += Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized() * randf() * get_value(emitter_radius)
	
	if local:
		add_child(p)
	else :
		get_parent().add_child(p)
		
	p.add_to_group(name)
	global.p_count += 1

func shape_changed(prop, value):
	if not gui.has("emitter_extents") and not gui.has("emitter_radius"):
		return 
	
	match (int(value)):
		0:
				gui["emitter_extents"].visible = false
				gui["emitter_radius"].visible = false
		1:
				gui["emitter_extents"].visible = true
				gui["emitter_radius"].visible = false
		2:
				gui["emitter_extents"].visible = false
				gui["emitter_radius"].visible = true

func motion_changed(prop, value):
	if not gui.has("sin_frequency") and not gui.has("cos_frequency") and not gui.has("sin_amplitude") and not gui.has("cos_amplitude"):
		return 
	
	match (int(value)):
		0:
			gui["sin_frequency"].visible = false
			gui["cos_frequency"].visible = false
			gui["sin_amplitude"].visible = false
			gui["cos_amplitude"].visible = false
		1:
			gui["sin_frequency"].visible = true
			gui["cos_frequency"].visible = true
			gui["sin_amplitude"].visible = true
			gui["cos_amplitude"].visible = true
		2:
			gui["sin_frequency"].visible = false
			gui["cos_frequency"].visible = false
			gui["sin_amplitude"].visible = false
			gui["cos_amplitude"].visible = false

func update_value_type(prop, type, control):
	match (type):
		0:
			set(prop, control.get_value())
			
		1:
			set(prop, Vector2(control.get_min_value(), control.get_max_value()))
			
			
		2:
			set(prop, control.get_curve())
			if get(prop).get_point_count() < 1:
				get(prop).add_point(Vector2(0, 0))
				get(prop).add_point(Vector2(1, 1))
			
	
	
func update_vector_type(prop, type, control):
	match (type):
		0:
			set(prop, control.get_vector())
		1:
			set(prop, control.get_range())

func update_property_value(prop, value, meta_data = ""):
	if prop in self:
		set(prop, value)
		if prop == "tex":
			if meta_data != "":
				texture_path = meta_data
			texture_filtering = true if value.flags == 4 else false
		
	else :
		print(prop + " is not a valid variable!")
		
func get_value(v, is_range = true):
	if typeof(v) == TYPE_REAL or typeof(v) == TYPE_INT:
		return v
	if typeof(v) == TYPE_VECTOR2:
		if is_range:
			return rand_range(v.x, v.y)
		else :
			return v
	if typeof(v) == TYPE_RECT2:
		return Vector2(rand_range(v.position.x, v.size.x), rand_range(v.position.y, v.size.y))
	if v is Curve:
		return v.interpolate_baked(time / duration)


func set_blend_mode(mode):
	
		
	material.blend_mode = mode
	blend_mode = mode

func get_blend_mode():
	return blend_mode
	
func cleanup_and_remove():
	emitting = false
	clear_particles()
	queue_free()

func clear_particles():
	var nodes = get_tree().get_nodes_in_group(name)
	for i in nodes:
		i.queue_free()
		global.p_count -= 1
		

func get_dict():
	var dict = {}
	dict["name"] = emitter_name
	dict["position"] = global.vec_to_dict(position)
	dict["local"] = local
	dict["loop"] = loop
	dict["blend_mode"] = blend_mode
	dict["layer"] = layer
	dict["p_properties"] = {}
	for i in properties:
		for k in properties[i]:
			var value = get(k)
			var type = typeof(value)
			
			match (typeof(value)):
				TYPE_INT, TYPE_REAL:
					dict["p_properties"][k] = {"value":get(k), "var_type":type}
				TYPE_VECTOR2:
					dict["p_properties"][k] = {"value":global.vec_to_dict(get(k)), "var_type":type}
				TYPE_RECT2:
					dict["p_properties"][k] = {"value":global.rect_to_dict(get(k)), "var_type":type}
				_:
					if value is Curve:
						dict["p_properties"][k] = {"value":global.curve_to_dict(get(k)), "var_type":"curve", "min":value.min_value, "max":value.max_value}
					if value is Gradient:
						dict["p_properties"][k] = {"value":global.gradient_to_dict(get(k)), "var_type":"gradient"}
					if value is Texture:
						dict["p_properties"][k] = {"value":texture_path, "var_type":"texture", "filtered":texture_filtering}
			
	return dict
	

