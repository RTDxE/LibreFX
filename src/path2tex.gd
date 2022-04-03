extends Node2D




var tex = ImageTexture.new()

func _ready():
	var image = Image.new()
	image.create(512, 512, false, Image.FORMAT_RGBAF)
	tex.create_from_image(image)
	$Path2D.curve.connect("changed", self, "path_to_tex")
	path_to_tex()
	pass



	

func path_to_tex():
	var image = Image.new()
	image.create(512, 512, false, Image.FORMAT_RGBAF)
	var curve = $Path2D.curve
	var count = curve.get_point_count()
	var length = curve.get_baked_length()
	image.lock()
	for i in range(0, length):
		
		$Path2D / PathFollow2D.offset = i
		var point = $Path2D / PathFollow2D.position
		
		
		image.set_pixel(i % 512, i / 512, Color(point.x / 512.0, point.y / 512.0, 0, 1))
		
	image.unlock()
	print(length)
	tex.create_from_image(image)
	
	
	pass
