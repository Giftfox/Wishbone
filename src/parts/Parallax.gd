class_name Parallax
extends Sprite2D

@export var looping_horizontal: bool = false
@export var looping_vertical: bool = false
@export var parallax_layer: float = 0
@export var horizontal_range: Vector2 = Vector2(0, 0)
@export var vertical_range: Vector2 = Vector2(0, 0)

@export var true_loop: bool = false
@export var set_z: bool = true

@onready var start_pos := global_position

func _ready():
	var start_rect = region_rect
	if looping_horizontal:
		if !true_loop:
			region_rect.end.x = 20000
		else:
			$Loop_left.texture = texture
			$Loop_left.region_rect = region_rect
			$Loop_left.position.x = -region_rect.end.x
	if looping_vertical:
		if !true_loop:
			region_rect.end.y = 20000
		else:
			$Loop_up.texture = texture
			$Loop_up.region_rect = region_rect
			$Loop_up.position.y = -region_rect.end.y

func _physics_process(delta):
	var ctrans = get_viewport().canvas_transform
	var view_pos = -ctrans.origin
	var view_end = view_pos + Global.VIEW_SIZE
	var view_middle = view_pos + (view_end - view_pos) / 2
	var pos_diff = start_pos - Vector2(view_pos.x, view_end.y - 250)
	
	if !true_loop:
		var spd = parallax_layer
		if parallax_layer > 0:
			spd = 1 * ((abs(parallax_layer)) * 0.1)
		else:
			spd = 1 * ((abs(parallax_layer)) * 0.25)
		spd = abs(spd)
		
		var inc = pos_diff * -sign(parallax_layer) * spd
		global_position = start_pos + Vector2(inc.x, inc.y / 4)
		
		if !looping_horizontal:
			global_position.x = clamp(global_position.x, start_pos.x + horizontal_range.x, start_pos.x + horizontal_range.y)
		else:
			pass#global_position.x = max(global_position.x, 0)
		if !looping_vertical:
			global_position.y = clamp(global_position.y, start_pos.y + vertical_range.x, start_pos.y + vertical_range.y)
		else:
			global_position.y = min(global_position.y, 0)
	else:
		if looping_horizontal:
			if $Loop_left.global_position.x - region_rect.end.x * scale.x > view_end.x or global_position.x + region_rect.end.x * scale.x < view_pos.x:
				global_position.x = view_pos.x
				
			if global_position.x < view_pos.x:
				global_position.x += region_rect.end.x * scale.x
			if $Loop_left.global_position.x > view_pos.x:
				global_position.x -= region_rect.end.x * scale.x
			
		if looping_vertical:
			if $Loop_up.global_position.y - region_rect.end.y * scale.y > view_end.y or global_position.y + region_rect.end.y * scale.y < view_pos.y:
				global_position.y = view_pos.y
			
			if global_position.y < view_pos.y:
				global_position.y += region_rect.end.y * scale.y
			if $Loop_up.global_position.y > view_pos.y:
				global_position.y -= region_rect.end.y * scale.y
	
	if set_z:
		if parallax_layer < 0:
			z_index = 100 + -parallax_layer
		else:
			z_index = -1 - parallax_layer
