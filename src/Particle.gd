extends Sprite






var emitter
var time = 1e-05
var lifetime = 2.0
var velocity = Vector2()
var start_pos
var size
var size_curve
var curve
var gradient
var angular_velocity
var velocity_multiplier
var orbital_velocity
var orbital_accum = Vector2()
var time_pos = 0.0
var frame_lifetime
var frame_count = 1

func _ready():
	var s = size_curve.interpolate_baked(time_pos)
	scale = Vector2(size, size) * s
	modulate = gradient.interpolate(time / max(lifetime, 0.0001))
	frame_count = vframes * hframes
	pass


func process(delta):
	time += delta
	time_pos = (time / max(lifetime, 0.0001))

	var diff = position - start_pos
	var ang = orbital_velocity.interpolate_baked(time_pos) * delta * 3.1416 * 2.0
	var rot = Transform2D(Vector2(cos(ang), - sin(ang)), Vector2(sin(ang), cos(ang)), Vector2())
	


	velocity += emitter.gravity * delta
	
	
	position -= diff
	position += rot * diff
	
	position += (velocity * velocity_multiplier.interpolate_baked(time_pos)) * delta

	modulate = gradient.interpolate(time_pos)
	var s = size_curve.interpolate_baked(time_pos)
	scale = Vector2(s, s) * size
	rotation_degrees += angular_velocity.interpolate_baked(time_pos)
	frame = wrapi(frame_lifetime.interpolate_baked(time_pos) * frame_count, 0, frame_count)
	
	if time >= lifetime:
		global.p_count -= 1
		queue_free()
