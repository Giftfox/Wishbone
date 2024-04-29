class_name EntityCamera
extends Node2D

@export var focus := false
@export var auto_center := true
@export var smooth := true
@export var offset_by_position := true
@export var platforming_movement := false

var current_pos := Vector2.ZERO
var target_pos := Vector2.ZERO
var boundary := Rect2(Vector2.ZERO, Vector2.ZERO)
var last_ground_pos := 0.0
var queue_off_floor := false
var was_on_floor := false

var gradual := false
var override := false

var shake_intensity := 0.0
var shake_current_offset := Vector2.ZERO

func _ready():
	if focus:
		snap_to_destination()
	if get_node_or_null("../Movement"):
		get_node("../Movement").jumping.connect(self._on_movement_leave_ground)

func _process(delta):
	# Camera shake
	if shake_intensity > 0:
		shake_current_offset = Vector2(randf_range(-5.0, 5.0) * shake_intensity, randf_range(-5.0, 5.0) * shake_intensity)
	else:
		shake_current_offset = Vector2.ZERO
		
	if focus:
		if !override:
			find_target_position()
			find_next_step()
			finalize_movement()
	else:
		if Global.get_camera():
			current_pos = Global.get_camera().current_pos

func snap_to_destination():
	find_target_position()
	current_pos = target_pos
	finalize_movement()
	
func shake_camera(time: float = 10.0, intensity: float = 1.0):
	$Shake.start(time)
	shake_intensity = intensity

func _on_shake_timeout():
	shake_intensity = 0.0

func find_target_position():
	var view = get_viewport()
	if boundary == Rect2(Vector2.ZERO, Vector2.ZERO):
		boundary = Rect2(Vector2(0, 0), Vector2(1000000, 1000000))
	
	var ppos = global_position
	
	if platforming_movement:
		var move = get_parent().get_node("Movement")
		if !move.on_floor or queue_off_floor:
			if was_on_floor and !queue_off_floor:
				last_ground_pos = ppos.y
			if queue_off_floor:
				queue_off_floor = false
				was_on_floor = false
				
			var high_threshold = Global.VIEW_SIZE.y - 50
			var low_threshold = 150
			if ppos.y < last_ground_pos - high_threshold:
				last_ground_pos -= abs(ppos.y - (last_ground_pos - high_threshold))
			#if ppos.y > last_ground_pos + low_threshold:
			#	last_ground_pos += abs(ppos.y - (last_ground_pos + low_threshold))
				
			ppos.y = last_ground_pos
		
		else:
			was_on_floor = move.on_floor
	
	if auto_center:
		ppos -= Vector2(view.size.x * 0.5, view.size.y * 0.75)
	
	target_pos = ppos
	target_pos.x = clamp(target_pos.x, boundary.position.x, boundary.end.x)
	target_pos.y = clamp(target_pos.y, boundary.position.y, boundary.end.y)
		
func find_next_step():
	var view = get_viewport()
	if current_pos == Vector2.ZERO:
		current_pos = -view.canvas_transform.origin
		
	var distance = target_pos - current_pos
	var spd = 0.12
	var next_pos = current_pos + distance * spd
	next_pos.x = floor(next_pos.x)
	next_pos.y = floor(next_pos.y)
	#if abs(target_pos.x - next_pos.x) < distance.x * spd && abs(target_pos.y - next_pos.y) < distance.y * spd:
	#	next_pos = target_pos
	if smooth:
		gradual = true
	
	if gradual and current_pos.distance_to(target_pos) > current_pos.distance_to(next_pos):
		current_pos = next_pos
	else:
		current_pos = target_pos
		gradual = false
		
func finalize_movement():
	if Global.current_room_control and Global.current_room_control.uses_camera:
		get_viewport().canvas_transform.origin = -(current_pos + shake_current_offset)
		if offset_by_position:
			get_viewport().canvas_transform.origin -= position
	else:
		get_viewport().canvas_transform.origin = Vector2.ZERO - shake_current_offset
		current_pos = Vector2.ZERO
	if Global.gui:
		Global.gui.reposition()

func _on_movement_leave_ground():
	last_ground_pos = global_position.y
	queue_off_floor = true
