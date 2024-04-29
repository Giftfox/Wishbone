class_name EntityAnimation
extends AnimatedSpriteEX

signal transition_finished(anim)

var parent
var frame_step := 0
var walk_foot := 0
var freeze := false
var movement_state := EntityMovement.State.IDLE
var animation_sequence := []

@export var match_walk_speed: bool = false
@export var auto_animate: bool = true

func _ready():
	self.animation_finished.connect(self._on_animation_finished)
		
func play_by_facing(anim: String = "", backwards: bool = false, face = -1):
	
	var success = super.play_by_facing(anim, backwards, face)
	play()
	return success
	#if !match_walk_speed:
	#	play()
	#else:
	#	stop()
	
func play_transition(anim: String = "", backwards: bool = false, face = -1):
	freeze = false
	var success = play_by_facing(anim, backwards, face)
	if success:
		parent.transitioning = true
	return success
	
func play_sequence(anims: Array):
	animation_sequence = anims
	play_next_in_sequence()
	
func play_next_in_sequence():
	if animation_sequence.size() == 1:
		play_by_facing(animation_sequence[0])
		animation_sequence.clear()
	else:
		play_transition(animation_sequence.pop_front())
	
func reset_animation():
	freeze = false
	var state = parent.get_node("Movement").movement_state
	_on_movement_state_changed(state, state, true)

func _on_movement_state_changed(_previous, new, override = false):
	if auto_animate and !parent.transitioning and ((_previous != new and !freeze) or override):
		movement_state = new
		if !get_parent().is_in_group("entity"):
			match new:
				EntityMovement.State.IDLE:
					if !["walk", "walk_startup", "jump"].has(current_anim) or !play_transition("walk_finish"):
						play_by_facing("idle")
				EntityMovement.State.RUNNING:
					if _previous == new or !play_transition("walk_startup"):
						play_by_facing("walk")
				EntityMovement.State.JUMPING:
					play_by_facing("jump")

func _finished_step():
	if match_walk_speed and sprite_frames:
		frame_step = Global.shift_index(frame_step, 0, sprite_frames.get_frame_count(animation) - 1, 1)
		if frame_step % 2 == 0:
			walk_foot = frame_step
		frame = frame_step

func _on_movement_facing_changed(_previous, new):
	facing = new #if new else facing

func _on_animation_finished():
	if parent.transitioning:
		parent.transitioning = false
		if animation_sequence.is_empty():
			var anim = current_anim
			var state = parent.get_node("Movement").movement_state
			_on_movement_state_changed(state, state, true)
			emit_signal("transition_finished", anim)
		else:
			play_next_in_sequence()
