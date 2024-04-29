class_name EventTrigger
extends Area2D

@export var attached_event := 0
@export var trigger_on_step := true
@export var trigger_on_interact := false
@export var pre_transition := false
@export var delete_flag := Enums.Flags.none
var entity_id := 0

var can_interact := false
		
func _ready():
	if delete_flag != Enums.Flags.none and Stats.get_flag(delete_flag) > 0:
		queue_free()
		
func _process(delta):
	if Global.current_pausestate == Global.PauseState.NORMAL or (pre_transition and Global.current_pausestate == Global.PauseState.TRANSITION):
		if trigger_on_interact and can_interact and Input.is_action_just_pressed("game_up"):
			run_trigger_event()
		
func run_trigger_event():
	if attached_event != 0:
		#if get_parent().is_in_group("entity") and get_parent().turn_when_interacted:
		#	get_parent().face_entity(Global.get_player())
		Event.run_event(attached_event, self)

func _on_body_entered(body):
	if body.is_in_group("player") and trigger_on_step:
		run_trigger_event()
	else:
		can_interact = true

func _on_body_exited(body):
	can_interact = false
