extends Particles2D




signal value_changed

enum VALUE_TYPE{NUMERIC, NUMERIC_SINGLE, VECTOR, VECTOR_NO_RANGE, COLOR, IMAGE, BOOL, OPTION, PIVOT}
var p_general = {"orig_pos":{"type":VALUE_TYPE.VECTOR_NO_RANGE, "min": - 10000, "max":1000, "name":"PROP_POSITION", "hint":"TIP_POSITION"}, 
				"random_seed":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":10000, "name":"PROP_RAND_SEED", "hint":"TIP_RAND_SEED"}, 
				"duration":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":100, "name":"PROP_DURATION", "hint":"TIP_DURATION"}, 
				"speed_scale":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":10, "name":"PROP_TIME_SCALE", "hint":"TIP_SPEED_SCALE"}, 
				"amount":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":1, "max":100000, "name":"PROP_AMOUNT", "hint":"TIP_AMOUNT"}, 
				"preprocess":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":100, "name":"PROP_PREPROCESS", "hint":"TIP_PREPROCESS"}, 
				"start_delay":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":100, "name":"PROP_DELAY", "hint":"TIP_DELAY"}, 
				"lifetime":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0.001, "max":100, "name":"PROP_LIFETIME", "hint":"TIP_LIFETIME"}, 
				"lifetime_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0.001, "max":100, "name":"PROP_LIFE_RANDOM", "hint":"TIP_LIFETIME_RANDOM"}, 
				"explosiveness":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_EXPLOSIVENESS", "hint":"TIP_EXPLOSIVENESS"}, 
					"gravity":{"type":VALUE_TYPE.VECTOR_NO_RANGE, "min": - 10000, "max":10000, "name":"PROP_GRAVITY", "hint":"TIP_GRAVITY"}, 
					"angle":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_EMITTER_ANGLE", "hint":"TIP_EMITTER_ANGLE"}, 
					"p_spread":{"type":VALUE_TYPE.NUMERIC, "min":0, "max":180, "name":"PROP_SPREAD", "hint":"TIP_SPREAD"}, 
					"emitter_spawn_offset":{"type":VALUE_TYPE.NUMERIC, "min":0, "max":180, "name":"PROP_SPAWN_OFFSET", "hint":"TIP_SPAWN_OFFSET"}, 
					"spread_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_SPREAD_RANDOM", "hint":"TIP_SPREAD_RANDOM"}}

var p_velocity = {"initial_velocity":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_INIT_VELOCITY", "hint":"TIP_INIT_VELOCITY"}, 
					"initial_velocity_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_INIT_VELOCITY_RANDOM", "hint":"TIP_INIT_VELOCITY"}, 
					"linear_acceleration":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_LINEAR_ACCEL", "hint":"TIP_LINEAR_ACCEL"}, 
					"linear_accel_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_LINEAR_ACCEL_RANDOM", "hint":"TIP_LINEAR_ACCEL_RANDOM"}, 
					"orbital_curve":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_ORBITAL_CURVE", "hint":"TIP_ORBITAL_CURVE"}, 
					"orbit_velocity_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_ORBIT_VELOCITY_RANDOM", "hint":"TIP_ORBIT_VELOCITY_RANDOM"}, 
					"radial_curve":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_RADIAL_CURVE", "hint":"TIP_RADIAL_CURVE"}, 
					"radial_accel_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_RADIAL_RANDOM", "hint":"TIP_RADIAL_RANDOM"}, 
					"tangent_curve":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_TANGENT_CURVE", "hint":"TIP_TANGENT_CURVE"}, 
					"tangent_accel_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_TANGENT_RANDOM", "hint":"TIP_TANGENT_RANDOM"}, 
					"damping_curve":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_DAMPING_CURVE", "hint":"TIP_DAMPING_CURVE"}, 
					"damping_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_DAMPING_RANDOM", "hint":"TIP_DAMPING_RANDOM"}}
					


var p_flow = {"use_flow_map":{"type":VALUE_TYPE.BOOL, "name":"PROP_USE_FLOW_MAP", "hint":"TIP_USE_FLOW_MAP"}, 
			"flow_map":{"type":VALUE_TYPE.IMAGE, "name":"PROP_FLOW_MAP_TEX", "hint":"TIP_FLOW_MAP_TEX"}, 
			"flow_map_multiplier":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_FLOW_MAP_MULTIPLIER", "hint":"TIP_FLOW_MAP_MULTIPLIER"}}

var p_motion = {"motion_type":{"type":VALUE_TYPE.OPTION, "items":["KEY_NONE", "KEY_SIN_COS"], "callback":"motion_changed", "name":"PROP_MOTION_TYPE", "hint":"TIP_MOTION_TYPE"}, 
				"sin_frequency":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_SIN_FREQ", "hint":"TIP_SIN_FREQ"}, 
				"cos_frequency":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_COS_FREQ", "hint":"TIP_COS_FREQ"}, 
				"sin_frequency_offset":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_SIN_FREQ_OFFSET", "hint":"TIP_SIN_FREQ_OFFSET"}, 
				"cos_frequency_offset":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_COS_FREQ_OFFSET", "hint":"TIP_COS_FREQ_OFFSET"}, 
				"sin_amplitude":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_SIN_AMP", "hint":"TIP_SIN_AMP"}, 
				"cos_amplitude":{"type":VALUE_TYPE.NUMERIC, "min": - 10000, "max":10000, "name":"PROP_COS_AMP", "hint":"TIP_COS_AMP"}}

var p_shape = {"emitter_shape":{"type":VALUE_TYPE.OPTION, "items":["SHAPE_POINT", "SHAPE_CIRCLE", "SHAPE_BOX"], "callback":"shape_changed", "name":"PROP_EMITTER_SHAPE", "hint":"TIP_EMITTER_SHAPE"}, 
			"emitter_width":{"type":VALUE_TYPE.NUMERIC, "min": - 1000, "max":1000, "name":"PROP_EMITTER_WIDTH", "hint":"TIP_EMITTER_WIDTH"}, 
			"emitter_height":{"type":VALUE_TYPE.NUMERIC, "min": - 1000, "max":1000, "name":"PROP_EMITTER_HEIGHT", "hint":"TIP_EMITTER_HEIGHT"}, 
			"emitter_min_radius":{"type":VALUE_TYPE.NUMERIC, "min": - 1000, "max":1000, "name":"PROP_EMITTER_MIN_RADIUS", "hint":"TIP_EMITTER_MIN_RADIUS"}, 
			"emitter_max_radius":{"type":VALUE_TYPE.NUMERIC, "min": - 1000, "max":1000, "name":"PROP_EMITTER_MAX_RADIUS", "hint":"TIP_EMITTER_MAX_RADIUS"}}

var p_image = {"tex":{"type":VALUE_TYPE.IMAGE, "name":"PROP_PARTICLE_TEX", "hint":"TIP_PARTICLE_TEX"}, 
				"tiles":{"type":VALUE_TYPE.VECTOR_NO_RANGE, "min":1, "max":1024, "name":"PROP_PARTICLE_TILES", "hint":"TIP_PARTICLE_TILES"}, 
				"anim_speed":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":100, "name":"PROP_PARTICLE_ANIM_SPEED", "hint":"TIP_PARTICLE_ANIM_SPEED"}, 
				"offset":{"type":VALUE_TYPE.PIVOT, "name":"PROP_OFFSET", "hint":"TIP_OFFSET"}}
				
				
var p_color = {"lifetime_color":{"type":VALUE_TYPE.COLOR, "name":"PROP_LIFETIME_COLOR", "hint":"TIP_LIFETIME_COLOR"}, 
				"hue_curve":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":360, "curve_default":Vector2(0.0, 360.0), "name":"PROP_PARTICLE_HUE_VARIATION", "hint":"TIP_PARTICLE_HUE_VARIATION"}, 
				"hue_variation_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_PARTICLE_HUE_VARIATION_RAND", "hint":"TIP_PARTICLE_HUE_VARIATION_RAND"}}

var p_angle = {"align_velocity":{"type":VALUE_TYPE.BOOL, "name":"PROP_PARTICLE_ALIGN", "hint":"TIP_PARTICLE_ALIGN"}, 
				"initial_angle":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_PARTICLE_INIT_ANGLE", "hint":"TIP_PARTICLE_INIT_ANGLE"}, 
				"initial_angle_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_PARTICLE_INIT_ANGLE_RANDOM", "hint":"TIP_PARTICLE_INIT_ANGLE_RANDOM"}, 
				"angle_offset":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 360, "max":360, "name":"PROP_PARTICLE_ANGLE_OFFSET", "hint":"TIP_PARTICLE_ANGLE_OFFSET"}, 
				"angular_velocity_curve":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_ANGULAR_VELOCITY_CURVE", "hint":"TIP_ANGULAR_VELOCITY_CURVE"}, 
				"angular_velocity_random":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_ANGULAR_VELOCITY_RANDOM", "hint":"TIP_ANGULAR_VELOCITY_RANDOM"}, 
				"lifetime_angle":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 10000, "max":10000, "name":"PROP_LIFETIME_ANGLE", "hint":"TIP_LIFETIME_ANGLE"}}

var p_size = {"lifetime_size":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 100, "max":100, "name":"PROP_LIFETIME_SIZE", "hint":"TIP_LIFETIME_SIZE"}, 
			"size_randomness":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min":0, "max":1, "name":"PROP_SIZE_RANDOM", "hint":"TIP_SIZE_RANDOM"}, 
			"lifetime_width":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 100, "max":100, "name":"PROP_LIFETIME_WIDTH", "hint":"TIP_LIMETIME_WIDTH"}, 
			"lifetime_height":{"type":VALUE_TYPE.NUMERIC_SINGLE, "min": - 100, "max":100, "name":"PROP_LIFETIME_HEIGHT", "hint":"TIP_LIFETIME_HEIGHT"}}

var properties = {"BUTTON_GENERAL":p_general, "BUTTON_SHAPE":p_shape, "BUTTON_TEXTURE":p_image, "BUTTON_VELOCITY":p_velocity, "BUTTON_COLOR":p_color, "BUTTON_SIZE":p_size, "BUTTON_ANGLE":p_angle, "BUTTON_FLOW_MAP":p_flow, "BUTTON_MOTION":p_motion}

var gui = {}

var materials = [preload("res://p_blend_mix.tres").duplicate(), preload("res://p_blend_add.tres").duplicate(), preload("res://p_blend_sub.tres").duplicate()]

var noise_time = 0.0
var delay_timer = 0.0
var delay_timer_running = false
var dragging = false
var index = 0
var invert_gravity = 1.0

var emitter_name = "Emitter"
var seamless = false
var visibility = true
var locked = false
var time = 0.0
var start_delay = 0.0
var duration = 1.0
var orig_pos
var layer = z_index
var local = false
var blend_mode = 0


var tex = preload("res://textures/soft_circle_64.png")
var tiles = Vector2(1, 1)
var angle = 0.0
var emitter_shape = 0
var emitter_width = 100.0
var emitter_height = 100.0
var emitter_min_radius = 0.0
var emitter_max_radius = 100.0
var emitter_spawn_offset = 0.0
var motion_type = 0
var sincos_ang = 0.0
var sin_frequency = 1.0
var cos_frequency = 1.0
var sin_frequency_offset = 0.0
var cos_frequency_offset = 0.0
var sin_amplitude = 10.0
var cos_amplitude = 10.0


var p_spread = 20.0
var rotation_randomness = 0.0
var size = 1.0
var size_randomness = 0.0
var lifetime_angle = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var linear_acceleration = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var hue_curve = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var orbital_curve = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var radial_curve = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var tangent_curve = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var lifetime_size = global.new_curve(Vector2(0, 1), Vector2(1, 0))
var lifetime_width = global.new_curve(Vector2(0, 1), Vector2(1, 1))
var lifetime_height = global.new_curve(Vector2(0, 1), Vector2(1, 1))
var damping_curve = global.new_curve(Vector2(0, 0), Vector2(1, 0))
var angular_velocity_curve = global.new_curve(Vector2(0, 0), Vector2(1, 0))

var start_angle = 0.0
var lifetime_color = Gradient.new()

var not_updating = true


func _ready():
	orig_pos = position
	var flow = preload("res://textures/flow_maps/no_flow.png")
	flow.set_meta("filtered", true)
	flow.set_meta("path", ProjectSettings.localize_path("res://textures/flow_maps/no_flow.png"))
	process_material.set_shader_param("flow_map", preload("res://textures/flow_maps/no_flow.png"))
	tex.set_meta("filtered", false)
	tex.set_meta("path", ProjectSettings.localize_path("res://textures/soft_circle_64.png"))
	process_material.set_shader_param("total", amount)
	
	material = materials[blend_mode]
	lifetime_color.set_color(0, Color(1, 1, 1, 1))
	lifetime_color.set_color(1, Color(1, 1, 1, 1))
	hook_up()
	yield (get_tree(), "idle_frame")
	
	delay_timer = start_delay
	delay_timer_running = true
	
	
	pass


func hook_up():
	local_coords = local
	
	z_index = layer
	
	material = materials[blend_mode]
	process_material.set_shader_param("seamless", seamless)
	
#	process_material.set_shader_param("scale_texture", CurveTexture.new())
#	process_material.set_shader_param("scale_x_tex", CurveTexture.new())
#	process_material.set_shader_param("scale_y_tex", CurveTexture.new())
	process_material.get_shader_param("scale_texture").curve = lifetime_size
	process_material.get_shader_param("scale_x_tex").curve = lifetime_width
	process_material.get_shader_param("scale_y_tex").curve = lifetime_height
	
#	process_material.set_shader_param("linear_accel_texture", CurveTexture.new())
#	process_material.set_shader_param("orbit_velocity_texture", CurveTexture.new())
#	process_material.set_shader_param("hue_variation_texture", CurveTexture.new())
#	process_material.set_shader_param("radial_accel_texture", CurveTexture.new())
#	process_material.set_shader_param("tangent_accel_texture", CurveTexture.new())
#	process_material.set_shader_param("damping_texture", CurveTexture.new())
#	process_material.set_shader_param("angle_texture", CurveTexture.new())
#	process_material.set_shader_param("angular_velocity_texture", CurveTexture.new())
#
	process_material.get_shader_param("linear_accel_texture").curve = linear_acceleration
	process_material.get_shader_param("orbit_velocity_texture").curve = orbital_curve
	process_material.get_shader_param("hue_variation_texture").curve = hue_curve
	process_material.get_shader_param("radial_accel_texture").curve = radial_curve
	process_material.get_shader_param("tangent_accel_texture").curve = tangent_curve
	process_material.get_shader_param("damping_texture").curve = damping_curve
	process_material.get_shader_param("angle_texture").curve = lifetime_angle
	process_material.get_shader_param("angular_velocity_texture").curve = angular_velocity_curve
	
	process_material.set_shader_param("emitter_angle", rotation_degrees)
	texture = tex
	normal_map = tex
	material.set_shader_param("particles_anim_h_frames", tiles.x)
	material.set_shader_param("particles_anim_v_frames", tiles.y)
	process_material.set_shader_param("emission_type", emitter_shape)
	
	
	
#	process_material.set_shader_param("color_ramp", GradientTexture.new())
	process_material.get_shader_param("color_ramp").gradient = lifetime_color

func spawn():
	pass

	
func process_emitter(delta):
	var dur = get_value(duration)
		
	if time >= duration + start_delay and one_shot:
		emitting = false

	if not one_shot:
		time = wrapf(time + delta, 0.0, duration + start_delay)
	else :
		time += delta
		
	noise_time = wrapf(noise_time + delta, 0.0, 1.0)
	
	process_material.set_shader_param("noise_time", noise_time)
	
	if delay_timer_running:
		delay_timer -= delta
		if delay_timer <= 0:
			print("starting")
			delay_timer_running = false
			restart()
			yield (get_tree(), "idle_frame")
			yield (get_tree(), "idle_frame")
			emitting = true
			visible = visibility

		
	if motion_type == 1 and emitting:
		sincos_ang += delta
		position = orig_pos + Vector2(sin(deg2rad(sincos_ang * get_value(sin_frequency) + get_value(sin_frequency_offset))) * get_value(sin_amplitude), cos(deg2rad(sincos_ang * get_value(cos_frequency) + get_value(cos_frequency_offset))) * get_value(cos_amplitude))
	else :
		position = orig_pos
		
	process_material.set_shader_param("spread", get_value(p_spread))
	process_material.set_shader_param("scale", get_value(size))
	process_material.set_shader_param("scale_random", get_value(size_randomness))
	process_material.set_shader_param("min_radius", get_value(emitter_min_radius))
	process_material.set_shader_param("max_radius", get_value(emitter_max_radius))
	process_material.set_shader_param("spawn_offset", get_value(emitter_spawn_offset))
	process_material.set_shader_param("emission_box_extents", Vector3(get_value(emitter_width), get_value(emitter_height), 0))
	
	visible = visibility
	rotation_degrees = get_value(angle) - 180
	process_material.set_shader_param("emitter_angle", - rotation_degrees + 180)
	process_material.set_shader_param("seamless", seamless)
	process_material.set_shader_param("total", amount)
	invert_gravity = - 1.0 if local else 1.0
	process_material.set_shader_param("gravity_invert", invert_gravity)
	VisualServer.force_draw(true, delta)

	
func start():
	
	
	noise_time = 0.0
	time = 0.0
	sincos_ang = 0.0
	if motion_type == 1:
		position = orig_pos + Vector2(sin(sincos_ang * get_value(sin_frequency) + get_value(sin_frequency_offset)) * get_value(sin_amplitude), cos(sincos_ang * get_value(cos_frequency) + get_value(cos_frequency_offset)) * get_value(cos_amplitude))
	else :
		position = orig_pos
	emitting = false
	
	
	delay_timer = start_delay
	delay_timer_running = true


	
func stop():
	visible = false
	yield (get_tree(), "idle_frame")
	yield (get_tree(), "idle_frame")
	emitting = false
	time = 0.0
	noise_time = 0.0
	sincos_ang = 0.0
	position = orig_pos
	
	
func shape_changed(prop, value):
	match (int(value)):
		0:
				gui["emitter_width"].visible = false
				gui["emitter_height"].visible = false
				gui["emitter_min_radius"].visible = false
				gui["emitter_max_radius"].visible = false
		1:
				gui["emitter_width"].visible = false
				gui["emitter_height"].visible = false
				gui["emitter_min_radius"].visible = true
				gui["emitter_max_radius"].visible = true
		2:
				gui["emitter_width"].visible = true
				gui["emitter_height"].visible = true
				gui["emitter_min_radius"].visible = false
				gui["emitter_max_radius"].visible = false

func motion_changed(prop, value):
	if not gui.has("sin_frequency") and not gui.has("cos_frequency") and not gui.has("sin_amplitude") and not gui.has("cos_amplitude"):
		return 
	
	match (int(value)):
		0:
			gui["sin_frequency"].visible = false
			gui["cos_frequency"].visible = false
			gui["sin_frequency_offset"].visible = false
			gui["cos_frequency_offset"].visible = false
			gui["sin_amplitude"].visible = false
			gui["cos_amplitude"].visible = false
		1:
			gui["sin_frequency"].visible = true
			gui["cos_frequency"].visible = true
			gui["sin_frequency_offset"].visible = true
			gui["cos_frequency_offset"].visible = true
			gui["sin_amplitude"].visible = true
			gui["cos_amplitude"].visible = true
		2:
			gui["sin_frequency"].visible = false
			gui["cos_frequency"].visible = false
			gui["sin_amplitude"].visible = false
			gui["cos_amplitude"].visible = false

	
func get_prop(prop):
	if prop == "gravity":
		return Vector2(process_material.get_shader_param("gravity").x, process_material.get_shader_param("gravity").y)
	var val = get(prop)
	if val == null:
		val = process_material.get_shader_param(prop)
	if val == null:
		val = material.get_shader_param(prop)
	return val
	
func set_prop(prop, value):
	if prop == "one_shot":
		one_shot = value
		emitting = true
	if prop == "gravity":
		process_material.set_shader_param(prop, Vector3(value.x, value.y, 0))
		return 
	if prop == "offset":
		material.set_shader_param(prop, value)
	if get(prop) != null:
		set(prop, value)
	else :
		process_material.set_shader_param(prop, value)
	hook_up()
	
func update_value_type(prop, type, control):
	match (type):
		0:
			set_prop(prop, control.get_value())
			
		1:
			set_prop(prop, Vector2(control.get_min_value(), control.get_max_value()))
			
			
		2:
			set_prop(prop, control.get_curve())
			if get_prop(prop).get_point_count() < 1:
				get_prop(prop).add_point(Vector2(0, 0))
				get_prop(prop).add_point(Vector2(1, 1))
			
	
	
func update_vector_type(prop, type, control):
	match (type):
		0:
			set_prop(prop, control.get_vector())
		1:
			set_prop(prop, control.get_range())
	
func update_property_value(prop, value):
	global.history.create_action("set property")
	global.history.add_do_method(self, "set_prop", prop, value)
	global.history.add_undo_method(self, "set_prop", prop, get_prop(prop))
	global.history.add_do_method(self, "emit_signal", "value_changed", prop, value)
	global.history.add_undo_method(self, "emit_signal", "value_changed", prop, value)
	global.history.commit_action()
	
	
	
	
		
		
			
				
			
		
	
		
			
		
	
		
		
func get_dict(base_dir):
	var dict = {}
	dict["name"] = emitter_name
	dict["position"] = global.vec_to_dict(position)
	dict["local"] = local
	dict["one_shot"] = one_shot
	dict["seamless"] = seamless
	dict["visibility"] = visibility
	dict["locked"] = locked
	dict["blend_mode"] = blend_mode
	dict["layer"] = z_index
	dict["p_properties"] = {}
	for i in properties:
		for k in properties[i]:
			var value = get_prop(k)
			var type = typeof(value)
			
			match (typeof(value)):
				TYPE_INT, TYPE_REAL:
					dict["p_properties"][k] = {"value":get_prop(k), "var_type":type}
				TYPE_VECTOR2:
					dict["p_properties"][k] = {"value":global.vec_to_dict(get_prop(k)), "var_type":type}
				TYPE_RECT2:
					dict["p_properties"][k] = {"value":global.rect_to_dict(get_prop(k)), "var_type":type}
				TYPE_BOOL:
					dict["p_properties"][k] = {"value":get_prop(k), "var_type":type}
				_:
					if value is Curve:
						dict["p_properties"][k] = {"value":global.curve_to_dict(get_prop(k)), "var_type":"curve", "min":value.min_value, "max":value.max_value}
					if value is Gradient:
						dict["p_properties"][k] = {"value":global.gradient_to_dict(get_prop(k)), "var_type":"gradient"}
					if value is Texture:
						var tex_path = value.get_meta("path")
						var index = tex_path.find(base_dir)
						var path = tex_path
						var relative = false
						if index > - 1:
							path = tex_path.substr(len(base_dir) + 1, len(tex_path))
							relative = true
							
						dict["p_properties"][k] = {"relative":relative, "value":path, "var_type":"texture", "filtered":value.get_meta("filtered")}
			
	return dict
	
func cleanup_and_remove():
	queue_free()
	pass
	
func set_blend_mode(mode):
	material = materials[mode]
	blend_mode = mode
	
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




func _on_Delay_timeout():
	restart()
	yield (get_tree(), "idle_frame")
	emitting = true
	visible = visibility
	pass
