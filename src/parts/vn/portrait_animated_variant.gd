class_name PortraitAnimatedVariant
extends AnimatedSprite2D

@export var randomize_frames := true : set = set_random
@export var blink_frames := false : set = set_blink
@export var frame_timer := 0.25
@export var blink_timer_range := Vector2(1.0, 5.0)

@export var anim_when_speaking := ""
@export var anim_when_not_speaking := ""

var waiting := true

func _ready():
	set_random(randomize_frames)
	set_blink(blink_frames)

func _process(delta):
	pass
	
func set_speaking(on):
	var old_visible = visible
	visible = (anim_when_speaking != "" and on) or (anim_when_not_speaking != "" and !on)
	if !old_visible and visible:
		frame = 0
		var new_anim = anim_when_speaking if on else anim_when_not_speaking
		if animation != new_anim:
			animation = new_anim
		set_speed()
		call_deferred("set_timer")

func set_blink(on):
	blink_frames = on
	call_deferred("set_timer")
	set_speed()
	
func set_random(on):
	randomize_frames = on
	call_deferred("set_timer")
	set_speed()
	
func set_speed():
	if randomize_frames or blink_frames:
		speed_scale = 0
		frame = 0
	else:
		speed_scale = 1
		play()
		
func set_waiting(on = false):
	waiting = on
	call_deferred("set_timer")

func _on_timer_timeout():
	if !waiting:
		if sprite_frames:
			if randomize_frames:
				var current_frame = frame
				var frames = sprite_frames.get_frame_count(animation)
				if frames > 1:
					while frame == current_frame:
						frame = randi_range(0, frames - 1)
			elif blink_frames:
				frame = 0
				speed_scale = 1
				play()
	set_timer()
	
func set_timer():
	if blink_frames:
		$Timer.start(randf_range(blink_timer_range.x, blink_timer_range.y))
	else:
		$Timer.start(frame_timer)

func _on_animation_finished():
	if blink_frames:
		frame = 0
		speed_scale = 0

func _on_animation_looped():
	if blink_frames:
		_on_animation_finished()
