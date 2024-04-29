class_name VNHandler
extends Node2D

var dialogue_resource = preload("res://src/parts/vn/DialogueBox.tscn")
var illustration_resource = preload("res://src/parts/vn/Illustration.tscn")
# 0 - resource, 1 - variants
var portrait_index = {
	"bel_cross": [preload("res://src/parts/vn/portraits/Beleth.tscn"), []],
	"andre_angry": [preload("res://src/parts/vn/portraits/Andre.tscn"), []],
	"novis": [preload("res://src/parts/vn/portraits/Novis.tscn"), []],
	"shizukan": [preload("res://src/parts/vn/portraits/Shizukan.tscn"), []],
	"nyaofa": [preload("res://src/parts/vn/portraits/Nyaofa.tscn"), []],
}
var dialogue_index = {
	"default": [preload("res://src/parts/vn/boxes/bubble.tscn")],
	"rectangle": [preload("res://src/parts/vn/boxes/rectangle.tscn")]
}

var screen_alpha_target := 0.0
var screen_alpha_max := 0.5

var finishing := false
var prepped := true

func _ready():
	Event.vn_handler = self

func _physics_process(delta):
	$Screen.modulate.a = Global.approach_value($Screen.modulate.a, screen_alpha_target, 0.05 * delta * 60)
	
	if finishing:
		prepped = true
		for n in get_tree().get_nodes_in_group("vn_portrait"):
			prepped = false
		for n in get_tree().get_nodes_in_group("vn_dialogue"):
			prepped = false
		for n in get_tree().get_nodes_in_group("vn_illustration"):
			prepped = false
		if prepped:
			finishing = false

func spawn_dialogue(portrait_id, dialogue_id, text, type = "default", clear_previous = true, mouth_override = -1, speaking_time = 3.0, extra_dist = Vector2.ZERO):
	for n in get_tree().get_nodes_in_group("vn_dialogue"):
		if n.persistent and n.id == dialogue_id:
			n.text = text
			n.attached_portrait = get_portrait(portrait_id)
			n.prepare()
			return n
			
	for p in get_tree().get_nodes_in_group("vn_portrait"):
		if p.id == portrait_id:
			if clear_previous:
				for d in p.get_children():
					if d is VNDialogueBox:
						if !d.persistent:
							d.clear()
			var dia = dialogue_index[type][0].instantiate()
			dia.text = text
			#dia.get_node("Fill/Label").text = text
			#dia.get_node("Fill/Label").modulate = p.dialogue_frame_col
			dia.id = dialogue_id
			#dia.get_node("Fill").self_modulate = p.dialogue_fill_col
			#dia.get_node("Fill/Frame").self_modulate = p.dialogue_frame_col
			#p.add_child(dia)
			add_child(dia)
			p.dialogue_boxes.append(dia)
			dia.attached_portrait = p
			dia.extra_dist = extra_dist
			dia.box_type = type
			dia.reposition()
			dia.prepare()
			return dia
	return null
	
func spawn_portrait(portrait_id, type, fadein = true, dir = 1, pos_offset = Vector2.ZERO, starting_pos = Vector2.ZERO):
	screen_alpha_target = screen_alpha_max
	var por = portrait_index[type][0].instantiate()
	por.dict_name = type
	$Portraits.add_child(por)
	if portrait_index[type][1].size() > 0:
		por.set_variants(portrait_index[type][1])
		
	if dir != 0:
		por.side = dir
		por.scale.x = dir
		por.position = Vector2.ZERO if dir == 1 else Vector2(Global.VIEW_SIZE.x * Global.WINDOW_SCALE, 0)
		if fadein:
			if starting_pos != Vector2.ZERO:
				por.position = starting_pos
			else:
				por.position.x -= (Global.VIEW_SIZE.x * Global.WINDOW_SCALE) * 0.3 * dir
			#por.position.y += por.placement_offset.y
			por.autoset_position(pos_offset)
		else:
			por.position.x += pos_offset.x * dir
			#por.position.y += por.placement_offset.y
			por.current_offset = pos_offset
	else:
		por.position = pos_offset
		
	por.id = portrait_id
	return por
	
func spawn_illustration(category, frames, image, instant_appear = true):
	var ill = illustration_resource.instantiate()
	$Illustration.add_child(ill)
	ill.instant_appear = instant_appear
	ill.category = category
	ill.frames = frames
	ill.id = image
	ill.appear(image)
	
func portrait_clear_all_dialogue(id):
	for n in get_tree().get_nodes_in_group("vn_dialogue"):
		if n.get_parent() is VNPortrait and n.get_parent().id == id:
			n.clear()

func clear_all_dialogue(half = false, keep_persistent = false):
	for n in get_tree().get_nodes_in_group("vn_dialogue"):
		if !keep_persistent or !n.persistent:
			if half:
				n.clear()
			else:
				n.clear_full()
				
func clear_illustration(category, id = "", instant = true):
	for n in get_tree().get_nodes_in_group("vn_illustration"):
		if category == n.category:
			if id == "" or id == n.id:
				if instant:
					n.queue_free()
				else:
					n.clear()
					
func clear_all_illustrations(instant = true):
	for n in get_tree().get_nodes_in_group("vn_illustration"):
		if instant:
			n.queue_free()
		else:
			n.clear()

func get_dialogue(id):
	for n in get_tree().get_nodes_in_group("vn_dialogue"):
		if n.id == id:
			return n
	return null
	
func get_portrait(id):
	for n in get_tree().get_nodes_in_group("vn_portrait"):
		if n.id == id and !n.freeing:
			return n
	return null
	
func get_illustration(id):
	for n in get_tree().get_nodes_in_group("vn_illustration"):
		if n.id == id:
			return n
	return null
	
func end_cutscene():
	finishing = true
	prepped = false
	screen_alpha_target = 0.0
	for n in get_tree().get_nodes_in_group("vn_portrait"):
		n.clear()
	for n in get_tree().get_nodes_in_group("vn_dialogue"):
		n.clear()
	for n in get_tree().get_nodes_in_group("vn_illustration"):
		n.clear()
