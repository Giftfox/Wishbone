class_name EntityMovement
extends Node2D

signal movement_state_changed(previous, new)
signal facing_changed(previous, new)
signal jumping()

enum State {
	IDLE,
	RUNNING,
	JUMPING,
	INACTIVE
}

var movement_state := State.IDLE
var facing := Global.Dirs.RIGHT

var movement_input := Vector2.ZERO
var vel := Vector2.ZERO
var on_floor := true
var drop_through := false
var drop_position := 0.0

@export var jump_speed := 335.0
@export var fall_speed_max := 600.0
@export var gravity := 20

@export var jump_auto_cancel := true
@export var active := true

@onready var real_position = get_parent().global_position

func _physics_process(delta):
	var prev_on_floor = on_floor
	on_floor = get_parent().is_on_floor()
	vel = get_parent().velocity
	
	if active:
		# Horizontal acceleration
		var accel = 10.0
		var target_speed = movement_input.x * 150.0
		if abs(vel.x) > abs(target_speed) or sign(vel.x) != sign(movement_input.x):
			accel = 20.0 # Deceleration when above max speed
		if !on_floor:
			accel *= 0.3 # Lower acceleration while in the air
		if on_floor or movement_input.x != 0:
			vel.x = Global.approach_value(vel.x, target_speed, accel * delta * 60)
		
		# Jumping
		var _jumping = false
		if movement_input.y < 0:
			if on_floor:
				vel.y = -jump_speed
				emit_signal("jumping")
				on_floor = false
				_jumping = true
				
		# Drop through platform
		if drop_through and movement_input.y > 0 and on_floor:
			vel.y = jump_speed / 4
			drop_position = real_position.y
			get_parent().set_collision_mask_value(2, false)
			emit_signal("jumping")
			on_floor = false
			_jumping = true
				
		# Gravity
		if !on_floor and !_jumping:
			vel.y = Global.approach_value(vel.y, fall_speed_max, gravity)
			# Allow/disallow holding down the jump button for repetitive jumps
			if jump_auto_cancel:
				movement_input.y = 0
			if prev_on_floor:
				emit_signal("jumping")
				
		var old_position = real_position
		
		# Move entity based on real position, and save the new real position
		get_parent().velocity = vel
		get_parent().global_position = real_position
		get_parent().move_and_slide()
		real_position = get_parent().global_position
		# Round the entity's position to a whole value
		get_parent().global_position = Vector2(round(get_parent().global_position.x), round(get_parent().global_position.y))
		
		if drop_through and (on_floor or real_position.y > drop_position + 16):
			drop_through = false
			get_parent().set_collision_mask_value(2, true)
		
		if get_parent().is_on_floor():
			if vel.x < 0:
				set_facing(Global.Dirs.LEFT)
			elif vel.x > 0:
				set_facing(Global.Dirs.RIGHT)
				
		if !get_parent().is_on_floor():
			set_movement_state(State.JUMPING)
		elif old_position.distance_to(real_position) > 1:
			if !prev_on_floor:
				set_movement_state(State.IDLE)
				get_parent().terrain_effects([Global.Dirs.LEFT, Global.Dirs.RIGHT])
				$EffectCooldown.start()
			else:
				set_movement_state(State.RUNNING)
				if $EffectCooldown.is_stopped():
					$EffectCooldown.start()
					get_parent().terrain_effects([-1])
		else:
			set_movement_state(State.IDLE)

func set_movement_state(state: State):
	if movement_state != state:
		emit_signal("movement_state_changed", movement_state, state)
		movement_state = state
	
func set_facing(new: Global.Dirs):
	emit_signal("facing_changed", facing, new)
	if facing != new:
		emit_signal("movement_state_changed", -1, movement_state)
	facing = new
	
func is_input_locked():
	match movement_state:
		State.INACTIVE:
			return true
			
	if Global.current_pausestate == Global.PauseState.TRANSITION:
		return true
		
	return false
