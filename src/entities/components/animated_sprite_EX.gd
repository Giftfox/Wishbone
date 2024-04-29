class_name AnimatedSpriteEX
extends AnimatedSprite2D

var facing: int = Global.Dirs.RIGHT
var current_anim := "idle"

var by_facing := false

@export var mirror_left: bool = true

func play_by_facing(anim: String = "", backwards: bool = false, face = -1):
	flip_h = false
	current_anim = anim
	
	if face != -1:
		facing = face
	
	var dir := ""
	match facing:
		Global.Dirs.LEFT:
			if mirror_left:
				flip_h = true
				dir = "_right"
			else:
				dir = "_left"
		Global.Dirs.RIGHT:
			dir = "_right"
			
	if sprite_frames and sprite_frames.has_animation(anim+dir):
		by_facing = true
		play(anim+dir, backwards)
		by_facing = false
		return true
	return false

#func play(anim = "", backwards = false, from_end = false):
#	if sprite_frames.has_animation(anim):
#		if !by_facing:
#			current_anim = anim
#		super.play(anim, backwards, from_end)
