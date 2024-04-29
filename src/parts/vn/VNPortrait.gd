class_name VNPortrait
extends Node2D

var target_pos := Vector2(-1, -1)
var current_offset := Vector2.ZERO
var clearing := false
var side := 1
var clear_side := 0
var current_variants := []
var current_replace_variants := []
var dialogue_boxes := []
var currently_speaking := false
var current_speaking_dialogue
var id := 0
var dict_name := ""
var freeing := false
var prepping := true

@export var dialogue_anchor := Vector2(770, 1070)
@export var dialogue_anchor_alt: Vector2
@export var dialogue_fill_col: Color = Color(1, 1, 1)
@export var dialogue_frame_col: Color = Color(0, 0, 0)
@export var fade_on_clear: bool = false
@export var default_variants: Array[String]

@export var distance_to_new_pos := 0.0
var old_pos := Vector2.ZERO

func _ready():
	if default_variants.size() > 0:
		set_variants(default_variants)
	set_speaking(false)

func _process(delta):
	if currently_speaking:
		var dia = Global.clear_object(current_speaking_dialogue)
		if !dia:
			currently_speaking = false
	if position != target_pos and target_pos != Vector2(-1, -1):
		if clearing:
			position.x = Global.approach_value(position.x, target_pos.x, 60)
		else:
			position = old_pos + distance_to_new_pos * (target_pos - old_pos)
			#position = Global.approach_vector_accel(position, target_pos, 10, delta, 16.0)
	elif prepping:
		prepping = false
		for c in Global.get_family(self):
			if c is PortraitAnimatedVariant:
				c.set_waiting()
	if clearing:
		if fade_on_clear:
			modulate.a = Global.approach_value(modulate.a, 0.0, 0.1)
		if (fade_on_clear and modulate.a <= 0.0) or (!fade_on_clear and position == target_pos):
			queue_free()
	
func clear(force_fade = false):
	if force_fade:
		fade_on_clear = true
	if !fade_on_clear:
		if clear_side == 0:
			clear_side = side
		target_pos = Vector2(-(Global.VIEW_SIZE.x * Global.WINDOW_SCALE) / 2, 0) if clear_side == 1 else Vector2((Global.VIEW_SIZE.x * Global.WINDOW_SCALE) * 1.5, 0)
	clearing = true
	set_speaking(false)
	for c in Global.get_family(self):
		if c is PortraitAnimatedVariant:
			c.set_waiting(true)
	unhook_dialogue()
	
func set_speaking(on, dialogue = null):
	currently_speaking = on
	if dialogue or !on:
		current_speaking_dialogue = dialogue
		
	for c in Global.get_family(self):
		if c is PortraitAnimatedVariant:
			c.set_speaking(on)
	
func set_variants(arr = [], replace_arr = []):
	if replace_arr.size() == 0:
		for c in $Portrait/Variants.get_children():
			c.visible = false
	else:
		for v in replace_arr:
			var node = get_node_or_null("Portrait/Variants/" + str(v))
			if node:
				node.visible = false
	for v in arr:
		var node = get_node_or_null("Portrait/Variants/" + str(v))
		if node:
			node.visible = true

func set_facing(dir, instant = false):
	if !$AnimationPlayer.is_playing():
		if instant:
			scale.x = dir
		if dir == -1:
			if scale.x != -1:
				scale.x = -1
				#$AnimationPlayer.play("flip")
		if dir == 1:
			if scale.x != 1:
				scale.x = 1
				#$AnimationPlayer.play_backwards("flip")

func autoset_position(new_offset):
	var base_pos = Vector2.ZERO if side == 1 else Vector2(Global.VIEW_SIZE.x * Global.WINDOW_SCALE, 0)
	target_pos = base_pos + Vector2(new_offset.x * side, new_offset.y)
	current_offset = new_offset
	old_pos = position
	distance_to_new_pos = 0.0
	$MovingAnimator.play("moving")

func unhook_dialogue():
	for c in get_children():
		if c is VNDialogueBox:
			var pos = c.global_position
			if get_parent():
				remove_child(c)
				get_parent().add_child(c)
			c.global_position = pos
			c.scale = scale
			c.clear()
	for d in dialogue_boxes:
		if Global.clear_object(d):
			d.clear()
		dialogue_boxes.erase(d)
		
func queue_free():
	unhook_dialogue()
	freeing = true
	super.queue_free()
