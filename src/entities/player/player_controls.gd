class_name PlayerControls
extends Node2D

@export var max_sens := 0.9
var controls_disabled := false
var MovementController
var fade_buffer := false
var input_buffer = {
}
var manual_buffer := false

var has_moved := false

func _ready():
	for c in get_parent().get_children():
		if c is EntityMovement:
			MovementController = c
			return
	push_error("No movement controller found for PlayerControls")
	
func _physics_process(_delta):
	var moveRight := 0.0
	var moveLeft := 0.0
	var moveDown := 0.0
	
	if !controls_disabled and Global.entity_active and !fade_buffer and !manual_buffer:
		# put max speed at 90% of the analog stick
		moveRight = sign(min(Input.get_action_strength("game_right") / max_sens, 1.0))
		moveLeft = sign(min(Input.get_action_strength("game_left") / max_sens, 1.0))
		moveDown = sign(min(Input.get_action_strength("game_down") / max_sens, 1.0))
		
		MovementController.movement_input.x = moveRight - moveLeft
		if Input.is_action_just_pressed("game_jump"):
			if moveDown > 0.0:
				MovementController.drop_through = true
				MovementController.movement_input.y = 1
			else:
				MovementController.movement_input.y = -1
	
	manual_buffer = false
