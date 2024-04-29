extends Area2D

enum actions {
	idle,
	walk_to_point
}

var active := true
var prev_state = Global.PauseState.NORMAL

var rect := Rect2(Vector2.ZERO, Vector2.ZERO)
var current_action := actions.idle
var destination := Vector2.ZERO

signal finished_action()

func _ready():
	if $Coll.shape:
		rect = $Coll.shape.get_rect()
		rect.position += get_parent().global_position
	$Coll.visible = false
	$Delay.start(randf_range(2.0, 5.0))
	
func _process(delta):
	if get_parent().ai_controlled_entity:
		get_parent().get_node("Movement").movement_input.x = 0
		
	var cancel = false
	if Global.current_pausestate != Global.PauseState.NORMAL and prev_state == Global.PauseState.NORMAL:
		cancel = true
	prev_state = Global.current_pausestate
		
	if active:
		if Global.current_pausestate == Global.PauseState.NORMAL:
			if current_action == actions.idle and get_parent().ai_controlled_entity and $Delay.is_stopped():
				current_action = actions.walk_to_point
				destination = get_parent().global_position
				while destination.distance_to(get_parent().global_position) < 50:
					destination = Vector2(randi_range(rect.position.x, rect.end.x), get_parent().global_position.y)
			
		if current_action == actions.walk_to_point:
			if get_parent().global_position.distance_to(destination) > 50 and !cancel:
				get_parent().get_node("Movement").movement_input.x = sign(destination.x - get_parent().global_position.x)
			else:
				current_action = actions.idle
				emit_signal("finished_action")
				$Delay.start(randf_range(2.0, 5.0))

func stop():
	current_action = actions.idle
	get_parent().get_node("Movement").movement_input.x = 0
	
func move_to_point(point):
	if point.y == 0:
		point.y = get_parent().global_position.y
	destination = point
	current_action = actions.walk_to_point

func move_distance(dist):
	destination = get_parent().global_position + dist
	current_action = actions.walk_to_point
