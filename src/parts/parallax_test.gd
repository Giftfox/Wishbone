extends Sprite2D

@export var spd := 1.0

func _process(delta):
	var view = get_viewport()
	offset.x = (view.canvas_transform.origin.x / 10) * spd
