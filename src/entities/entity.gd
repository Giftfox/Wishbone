@tool

class_name Entity
extends CharacterBody2D

enum characters {
	none,
	
	aki,
	biff,
	fan,
	fennelf,
	goatato,
	histle,
	jupet,
	khatira,
	krypto,
	lilyexplorer,
	msrah,
	naki,
	neonexplorer,
	pendragon,
	pepper,
	price,
	thornbird,
	yasin,
	shizukan,
	nyaofa
}
enum char_info_elements {anim_offset, mirror_left, shape_size, uses_ai, frames_resource}
var char_info = {
	characters.none: [Vector2(0, 0), true, Vector2(38, 61), true, null],
	
	characters.fan: [Vector2(0, -40), true, Vector2(32, 61), true, preload("res://src/entities/individuals/frames/althar_fan.tres")],
	characters.pepper: [Vector2(0, -48), false, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/pepper.tres")],
	characters.aki: [Vector2(0, -48), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/aki.tres")],
	characters.biff: [Vector2(0, -40), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/biff.tres")],
	characters.fennelf: [Vector2(0, -32), true, Vector2(38, 61), false, preload("res://src/entities/individuals/frames/fennelf.tres")],
	characters.goatato: [Vector2(0, -29.5), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/goatato.tres")],
	characters.histle: [Vector2(0, -18), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/histle.tres")],
	characters.jupet: [Vector2(0, -16), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/jupet.tres")],
	characters.khatira: [Vector2(0, -48), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/khatira.tres")],
	characters.krypto: [Vector2(0, -24), false, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/krypto.tres")],
	characters.lilyexplorer: [Vector2(0, -40), false, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/lilyexplorer.tres")],
	characters.msrah: [Vector2(0, -48), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/msrah.tres")],
	characters.naki: [Vector2(0, -40), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/naki.tres")],
	characters.neonexplorer: [Vector2(0, -40), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/neonexplorer.tres")],
	characters.pendragon: [Vector2(0, -48), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/pendragon.tres")],
	characters.price: [Vector2(0, -48), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/price.tres")],
	characters.thornbird: [Vector2(0, -48), true, Vector2(38, 61), false, preload("res://src/entities/individuals/frames/thornbird.tres")],
	characters.yasin: [Vector2(0, -48), true, Vector2(38, 61), true, preload("res://src/entities/individuals/frames/yasin.tres")],
	characters.shizukan: [Vector2(0, -64), false, Vector2(32, 106), true, preload("res://src/entities/individuals/frames/shizukan.tres")],
	characters.nyaofa: [Vector2(0, -16), true, Vector2(14, 19), true, preload("res://src/entities/individuals/frames/nyaofa.tres")],
}

enum effects_elements {resource, pos, directional}
var effects_info = {
	Enums.Terrain.sand: [preload("res://src/entities/effects/sand.tscn"), Vector2.ZERO, true]
}

@export var character := characters.fan : set = set_character
@export var auto_adjust_character := true
@export var ai_controlled := false
var ai_controlled_entity := false
var animated_sprite
var transitioning := false

func _ready():
	$Coll.shape = $Coll.shape.duplicate()
	ai_controlled_entity = ai_controlled
	set_character(character)
	
	for c in Global.get_family(self):
		if c is EntityAnimation:
			c.parent = self
			animated_sprite = c
	if animated_sprite:
		animated_sprite.transition_finished.connect(self._on_animation_transition_finished)

func _process(delta):
	pass
	
func set_character(ch):
	character = ch
	
	if auto_adjust_character:
		$Visuals/Anims.sprite_frames = char_info[ch][char_info_elements.frames_resource]
		$Visuals/Anims.position = char_info[ch][char_info_elements.anim_offset]
		$Visuals/Anims.mirror_left = char_info[ch][char_info_elements.mirror_left]
		$Coll.shape.size = char_info[ch][char_info_elements.shape_size]
		$Coll.position.y = -$Coll.shape.size.y / 2
		ai_controlled_entity = ai_controlled and char_info[ch][char_info_elements.uses_ai]

func spawn_effect(eff, dir = -1):
	var effect = effects_info[eff][effects_elements.resource].instantiate()
	add_child(effect)
	effect.position = effects_info[eff][effects_elements.pos]
	if effects_info[eff][effects_elements.directional]:
		if dir == -1:
			dir = $Movement.facing
		if dir == Global.Dirs.LEFT:
			effect.scale.x = -1
	effect.prep()

func terrain_effects(dirs = [-1]):
	var _types = []
	for map in Global.current_tilemaps:
		var new_types = map.seek_terrain(global_position + Vector2(0, 1))
		for _type in new_types:
			if !_types.has(_type):
				_types.append(_type)
	for t in _types:
		for d in dirs:
			spawn_effect(t, d)

func _on_animation_transition_finished(anim):
	pass
