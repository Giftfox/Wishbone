class_name VNDialogueBox
extends Node2D

var id := 0
var extra_dist := Vector2.ZERO
var attached_portrait
var clearing := 0

var text_writing := true
var text := ""
var text_pointer := 0
var box_type := ""

@export var dist_from_origin := Vector2.ZERO

@export var persistent := false
@export var auto_position := true

func _ready():
	$AnimationPlayer.animation_finished.connect(self._on_AnimationPlayer_animation_finished)
	$AnimationPlayer.play("fadein")

func _process(delta):
	reposition()
	
func reposition():
	if auto_position:
		if attached_portrait:
			$Fill/Frame.scale = Vector2(attached_portrait.side, 1)
			if attached_portrait.side == 1:
				position = Vector2(1300, 1350)
			else:
				position = Vector2(1300, 1350)
				
		$Fill.position = Vector2(300 * attached_portrait.scale.x, 140) * Global.WINDOW_SCALE * dist_from_origin

func prepare():
	$Fill/Label.text = ""
	text_pointer = 0
	text_writing = true
	if attached_portrait:
		attached_portrait.set_speaking(true, self)
		
func skip_text():
	text_pointer = text.length()
	text_writing = false
	attached_portrait.set_speaking(false)
	$Fill/Label.text = text

func clear():
	if !$AnimationPlayer.is_playing():
		#$AnimationPlayer.play("fadeout")
		clearing += 1
		if clearing == 1:
			$AnimationPlayer.play("fadeout_half")
		else:
			$AnimationPlayer.play("fadeout_half_2")
		
func clear_full():
	if clearing == 0:
		$AnimationPlayer.play("fadeout")
	else:
		$AnimationPlayer.play("fadeout_half_2")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeout" or anim_name == "fadeout_half_2":
		queue_free()

func _on_text_advance_timeout():
	if text_pointer < text.length():
		text_pointer += 1
		$Fill/Label.text = text.substr(0, text_pointer)
		if text_pointer == text.length():
			attached_portrait.set_speaking(false)
			text_writing = false
