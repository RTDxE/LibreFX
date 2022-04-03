extends Button




var grid

func _ready():
	connect("pressed", self, "show_properties")
	pass


func show_properties():
	if grid:
		grid.visible = not grid.visible

func set_text(t):
	text = t
