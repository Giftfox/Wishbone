class_name WarpPoint
extends EventTrigger

# For reference, "entrance" represents entering a map,
# while "exit" represents exiting a map
@export var is_entrance := true
@export var is_exit := true
@export var move_after_entering := true
@export var enter_direction := Global.HDirs.RIGHT

@export var linked_map := ""
@export var linked_entrance := ""
@export var entrance_name := ""
@export var entrance_id := 1

var buffer_exit := false

func _ready():
	if is_entrance:
		add_to_group("warp_entrance")
	if is_exit:
		add_to_group("warp_exit")
		
func run_trigger_event():
	Global.new_room_entrance = linked_entrance
	Global.saved_room_path = Global.current_room_path
	Global.saved_room_entrance = entrance_name
	Global.current_room_control.room_change(linked_map, true)
		
func move_player():
	var off := Vector2.ZERO
	#match enter_direction:
	#	Global.Dirs.LEFT:
	#		off.x = -Global.TILE_SIZE
	#	Global.Dirs.RIGHT:
	#		off.x = Global.TILE_SIZE
	#	Global.Dirs.UP:
	#		off.y = -Global.TILE_SIZE
	#	Global.Dirs.DOWN:
	#		off.y = Global.TILE_SIZE
	Global.get_player().global_position = global_position + off
	#if move_after_entering:
	#	Global.player_x_offset = Global.dir2vector(enter_direction).x
	#	Global.player_y_offset = Global.dir2vector(enter_direction).y
	#	Global.get_player().get_node("Movement").facing = enter_direction
	#	Global.get_player().get_node("Movement").move_by_force(Global.dir2vector(enter_direction))

func _on_body_entered(body):
	if is_exit and !buffer_exit:
		super._on_body_entered(body)

func _on_body_exited(body):
	buffer_exit = false
	super._on_body_exited(body)
