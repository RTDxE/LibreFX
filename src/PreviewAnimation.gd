extends TextureRect






export (NodePath) var slider_path
var frame_slider
var frame = 0.0
var frame_width = 256.0
var frame_height = 256.0
var tex_width = 256.0
var tex_height = 256.0
var tex
var max_frame = 0
var image_data
var render_scale = 1.0
var playing = true
func _ready():
	frame_slider = get_node(slider_path)
	pass


func _physics_process(delta):
	max_frame = (tex_width * tex_height) / (global.render_size.x * global.render_size.y)
	
	frame_slider.max_value = global.frame_amount - 1
	
	if playing:
		frame += global.render_fps / 60.0
		frame = wrapf(frame, 0, global.frame_amount)
		frame_slider.value = frame
	
	update()

func _draw():
	draw_texture_rect(global.checker, Rect2(Vector2(0, 0), rect_size), true)
	var frames_per_row = round(floor(tex_width * render_scale) / floor(global.render_size.x * render_scale))
	var y = floor(frame / frames_per_row) * (global.render_size.y * render_scale)
	var x = floor(fmod(frame, frames_per_row)) * (global.render_size.x * render_scale)
	
	
		
	if tex:
		draw_texture_rect_region(tex, Rect2(Vector2(0, 0), global.render_size), Rect2(x, y, global.render_size.x * render_scale, global.render_size.y * render_scale))


func _on_RenderButton_pressed():
	
	
	rect_min_size = global.render_size
	rect_size = global.render_size
	yield (get_tree(), "idle_frame")



	
		
		
	tex = null
	pass


func _on_RenderHeight_value_changed(value):
	tex = null
	pass

func clear():
	tex = null
	
func set_tex(t):
	image_data = t.get_data()
	tex = t

func _on_RenderScale_value_changed(value):
	render_scale = value / 100.0
	var temp = image_data.duplicate()
	temp.resize(temp.get_width() * (value / 100.0), temp.get_height() * (value / 100.0), 0)
	var t = ImageTexture.new()
	t.create_from_image(temp)
	t.flags = 0
	tex = t
	pass


func _on_PlayPreview_pressed():
	playing = true
	pass


func _on_StopPreview_pressed():
	playing = false
	pass


func _on_FrameSlider_value_changed(value):
	frame = value
	pass
