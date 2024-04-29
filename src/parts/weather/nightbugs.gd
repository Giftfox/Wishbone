extends Node2D

var particle_resource = preload("res://src/parts/weather/nightbug_particles.tscn")

var particles := []
var parallax_speeds := [0.5, -0.2]
var z_indexes := [-200, 200]
var sizes := [1.0, 2.0]
var alphas := [0.4, 0.6]

func _ready():
	var arr = []
	for j in range(parallax_speeds.size()):
		var node = Node2D.new()
		add_child(node)
		particles.append(node)
		for i in range(4):
			var part = particle_resource.instantiate()
			part.z_index = z_indexes[j]
			part.modulate.a = alphas[j]
			part.scale_amount_min *= sizes[j]
			part.scale_amount_max *= sizes[j]
			node.add_child(part)
			if i != 0:
				part.position = Global.VIEW_SIZE * 2

func _process(delta):
	var ct = -get_viewport().canvas_transform.origin
	var j = 0
	for group in particles:
		group.position = ct * parallax_speeds[j]
		var closest
		var positions = []
		for part in group.get_children():
			positions.append(part.position)
			if !closest or closest.global_position.distance_to(ct + Global.VIEW_SIZE / 2) > part.global_position.distance_to(ct + Global.VIEW_SIZE / 2):
				closest = part
		var i = 0
		var off = Vector2.ZERO
		for part in group.get_children():
			if part != closest and !Rect2(Vector2(ct.x, ct.y), Global.VIEW_SIZE).intersects(Rect2(part.global_position - part.emission_rect_extents, part.emission_rect_extents * 2)):
				var failed = true
				while failed and i < 3:
					match i:
						0:
							off.x = Global.VIEW_SIZE.x * 2 if ct.x > closest.global_position.x else -Global.VIEW_SIZE.x * 2
							if !positions.has(closest.position + off):
								part.position = closest.position + off
								failed = false
						1:
							off.y = Global.VIEW_SIZE.y * 2 if ct.y > closest.global_position.y else -Global.VIEW_SIZE.y * 2
							if !positions.has(closest.position + Vector2(0, off.y)):
								part.position = closest.position + Vector2(0, off.y)
								failed = false
						2:
							if !positions.has(closest.position + off):
								part.position = closest.position + off
								failed = false
					i += 1
		j += 1
