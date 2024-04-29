extends Node

const TILE_SIZE = 16
const ONE_FRAME = 1.0/60.0
const VIEW_SIZE = Vector2(640, 360)
const WINDOW_SCALE = 4

enum PauseState {
	NORMAL,
	PAUSED,
	TRANSITION,
	EVENT,
	HITLAG,
	TIME_PAUSED
}

var hitlag_time := -1
var current_pausestate = PauseState.NORMAL
var old_pausestate = PauseState.NORMAL
var entity_active = true

var current_room
var current_room_control
var current_room_path := ""
var current_tilemaps := []

var saved_room_path := ""
var saved_room_entrance := ""
var new_room_entrance := ""
var entrance_id := 0
var gui

var player_x := 0
var player_y := 0
var player_x_offset := 0
var player_y_offset := 0

var mouse_pos := Vector2.ZERO

# flag values stolen shamelessly from BYOND
enum Dirs {
	UP = 1,
	DOWN = 2,
	RIGHT = 4,
	LEFT = 8,
}
enum Diags {
	UP_RIGHT = Dirs.UP|Dirs.RIGHT,
	UP_LEFT = Dirs.UP|Dirs.LEFT,
	DOWN_RIGHT = Dirs.DOWN|Dirs.RIGHT,
	DOWN_LEFT = Dirs.DOWN|Dirs.LEFT,
}

# used for iteration, exports, etc
enum AllDirs {
	UP = Dirs.UP,
	DOWN = Dirs.DOWN,
	RIGHT = Dirs.RIGHT,
	LEFT = Dirs.LEFT,
	UP_RIGHT = Diags.UP_RIGHT,
	UP_LEFT = Diags.UP_LEFT,
	DOWN_RIGHT = Diags.DOWN_RIGHT,
	DOWN_LEFT = Diags.DOWN_LEFT,
}
enum HDirs {
	RIGHT = Dirs.RIGHT,
	LEFT = Dirs.LEFT,
}
enum VDirs {
	UP = Dirs.UP,
	DOWN = Dirs.DOWN,
}

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	
func _physics_process(delta):
	if hitlag_time > -1:
		hitlag_time -= 1 + delta
		if hitlag_time <= 0:
			hitlag_time = -1
			set_pause_state(old_pausestate)
	
	mouse_pos = get_viewport().get_mouse_position()
			
func vec_scale_x_to(v: Vector2, x: float) -> Vector2:
	v = v.normalized()
	v /= v.x
	return v * x

func vec_scale_y_to(v: Vector2, y: float) -> Vector2:
	v = v.normalized()
	v /= v.y
	return v * y
	
func scale_range_to(x: float, y_min: float, y_max: float) -> float:
	return y_min*(1-x) + y_max*x
	
func vector2dir(v: Vector2, diagonals := false) -> int:
	v.y *= -1 # flip over x axis to match real world angles
	
	var dir := 0
	var angle_step = (PI/4 if diagonals else PI/2)/2
	
	if abs(v.angle_to(rad2vector(0))) < angle_step:
		dir = Dirs.RIGHT
	if abs(v.angle_to(rad2vector(PI/2))) < angle_step:
		dir = Dirs.UP
	if abs(v.angle_to(rad2vector(PI))) < angle_step:
		dir = Dirs.LEFT
	if abs(v.angle_to(rad2vector(PI*3/2))) < angle_step:
		dir = Dirs.DOWN
	
	if dir == 0 or diagonals:
		if abs(v.angle_to(rad2vector(PI/4))) < PI/4:
			dir = Diags.UP_RIGHT
		if abs(v.angle_to(rad2vector(PI*3/4))) < PI/4:
			dir = Diags.UP_LEFT
		if abs(v.angle_to(rad2vector(PI*5/4))) < PI/4:
			dir = Diags.DOWN_LEFT
		if abs(v.angle_to(rad2vector(PI*7/4))) < PI/4:
			dir = Diags.DOWN_RIGHT
		
		if !diagonals:
			match dir:
				Diags.UP_RIGHT:
					dir = Dirs.RIGHT
				Diags.UP_LEFT:
					dir = Dirs.LEFT
				Diags.DOWN_RIGHT:
					dir = Dirs.RIGHT
				Diags.DOWN_LEFT:
					dir = Dirs.LEFT

	if not dir: push_error("no dir")
	return dir

func dir2vector(dir):
	var vec = Vector2.ZERO
	match dir:
		Dirs.LEFT:
			vec = Vector2(-1, 0)
		Dirs.RIGHT:
			vec = Vector2(1, 0)
		Dirs.UP:
			vec = Vector2(0, -1)
		Dirs.DOWN:
			vec = Vector2(0, 1)
	return vec
	
func polar2cartesian(rad, angle):
	var x = rad * cos(angle)
	var y = rad * sin(angle)
	return Vector2(x, y)
	
func rad2vector(angle) -> Vector2:
	return polar2cartesian(1, angle)

#func deg2vector(angle) -> Vector2:
#	return rad2vector(deg2rad(angle))
			
func get_dir(from: Vector2, to: Vector2, diagonals: bool = true) -> int:
	return vector2dir(rad2vector(to.angle_to_point(from)), diagonals)
	
func get_cardinal(from: Vector2, to: Vector2) -> int:
	return get_dir(from, to, false)
	
func get_diagonal(from: Vector2, to: Vector2) -> int:
	var dir = get_dir(from, to)
	match dir:
		Dirs.UP:
			if to.x < from.x:
				dir = Diags.UP_LEFT
			else:
				dir = Diags.UP_RIGHT
		Dirs.DOWN:
			if to.x < from.x:
				dir = Diags.DOWN_LEFT
			else:
				dir = Diags.DOWN_RIGHT
		Dirs.LEFT:
			if to.y < from.y:
				dir = Diags.UP_LEFT
			else:
				dir = Diags.DOWN_LEFT
		Dirs.RIGHT:
			if to.y < from.y:
				dir = Diags.UP_RIGHT
			else:
				dir = Diags.DOWN_RIGHT
	return dir
	# asdfasdf

func opposite_dir(dir) -> int:
	var new_dir = 0
	match dir:
		Dirs.LEFT:
			new_dir = Dirs.RIGHT
		Dirs.RIGHT:
			new_dir = Dirs.LEFT
		Dirs.UP:
			new_dir = Dirs.DOWN
		Dirs.DOWN:
			new_dir = Dirs.UP
			
		Diags.UP_LEFT:
			new_dir = Diags.DOWN_RIGHT
		Diags.UP_RIGHT:
			new_dir = Diags.DOWN_LEFT
		Diags.DOWN_LEFT:
			new_dir = Diags.UP_RIGHT
		Diags.DOWN_RIGHT:
			new_dir = Diags.UP_LEFT
			
	return new_dir
	
func distance_to_vector(from: Vector2, to: Vector2, diagonal_equal := false) -> float:
	var dist = 0
	dist += abs(from.x - to.x)
	if diagonal_equal:
		dist = max(dist, abs(from.y - to.y))
	else:
		dist += abs(from.y - to.y)
	return dist
	
func approach_value(current: float, target: float, increase: float) -> float:
	if target != current:
		if target < current:
			increase *= -1
		current += increase
		if abs(target - current) < abs(increase):
			current = target
		
	return current
	
func approach_vector(current: Vector2, target: Vector2, increase: float) -> Vector2:
	if target != current:
		current -= rad2vector(current.angle_to_point(target)) * increase
		if current.distance_to(target) < increase:
			current = target
		
	return current
	
func approach_decel(current, target, maxdist, topspd, delta, bottomspd = 0.1):
	if current != target:
		var dist_remaining = abs(target - current)
		var spd = (((dist_remaining / maxdist) * (topspd - bottomspd)) + bottomspd) * delta * 60
		if current > target:
			spd = -spd

		if (current < target and current + spd > target) or (current > target and current + spd < target):
			spd = target - current

		return current + spd
	return current
	
func approach_vector_accel(current: Vector2, target: Vector2, increase: float, delta = 0, accel_threshold_mod = 4.0) -> Vector2:
	if target != current:
		var dist = current.distance_to(target)
		#var max_dist = origin.distance_to(target) * accel_threshold_mod
		var max_dist = increase * accel_threshold_mod
		var mod = 1.0
		if dist < max_dist:
			mod = dist / max_dist
		mod = max(mod, 0.1)
		
		var change = rad2vector(current.angle_to_point(target)) * increase * mod
		if delta != 0:
			change *= delta * 60
		current -= change
		if current.distance_to(target) < increase:
			current = target
		
	return current
	
func snap_vector(pos: Vector2):
	var cell_x = floor(pos.x / float(TILE_SIZE)) + 0.5
	var cell_y = floor(pos.y / float(TILE_SIZE)) + 0.5
	pos = Vector2(cell_x * TILE_SIZE, cell_y * TILE_SIZE)
	return pos
	
func get_cardinal_input(left = "menu_left", right = "menu_right", up = "menu_up", down = "menu_down"):
	var shift = Vector2.ZERO
	if left != "" and Input.is_action_just_pressed(left):
		shift.x -= 1
	if right != "" and Input.is_action_just_pressed(right):
		shift.x += 1
	if up != "" and Input.is_action_just_pressed(up):
		shift.y -= 1
	if down != "" and Input.is_action_just_pressed(down):
		shift.y += 1
	return shift
	
func shift_input(decrease_input, increase_input, buffered = false, buffer = 0.1):
	var shift = 0
	if buffered:
		if InputActions.is_action_buffered(decrease_input, buffer):
			shift -= 1
		if InputActions.is_action_buffered(increase_input, buffer):
			shift += 1
	else:
		if Input.is_action_just_pressed(decrease_input):
			shift -= 1
		if Input.is_action_just_pressed(increase_input):
			shift += 1
	return shift
	
func shift_index(current, minval, maxval, inc):
	current += inc
	if current > maxval:
		current = minval + (current - 1) - maxval
	if current < minval:
		current = maxval - minval - (abs(current) - 1)
		
	return current
	
func array_has_deep(arr, index, position = -999):
	for i in arr:
		if position == -999:
			return i.has(index)
		else:
			return i.size() > position and i[position] == index
	return false
	
func array_get_deep(arr, index, position = -999):
	var i = 0
	for a in arr:
		if position == -999:
			if a.has(index):
				return i
		else:
			if a.size() > position and a[position] == index:
				return i
		i += 1
	return -1
	
func clamp_degrees(deg) -> float:
	return fposmod(deg, 360)
	
func clear_object(obj):
	if !is_instance_valid(obj):
		return null
	return obj
	
func get_family(scene):
	var nodes := []
	for c in scene.get_children():
		if !c.get_children().is_empty():
			var extra_nodes = get_family(c)
			for n in extra_nodes:
				nodes.append(n)
		nodes.append(c)
	return nodes
	
func get_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
	
func set_hitlag(frames := 12):
	hitlag_time = max(frames, hitlag_time)
	set_pause_state(PauseState.HITLAG)
	
func get_camera():
	var cams = get_tree().get_nodes_in_group("camera")
	var cam = null
	for c in cams:
		if c.focus:
			cam = c
			break
	return cam

func set_pause_state(ps = PauseState.NORMAL):
	if current_pausestate != ps:
		old_pausestate = current_pausestate
	current_pausestate = ps
	var tree = get_tree()
	
	tree.set_group_flags(2, "player", "process_mode", PROCESS_MODE_PAUSABLE)
	tree.set_group_flags(2, "view", "process_mode", PROCESS_MODE_PAUSABLE)
	tree.set_group_flags(2, "entity", "process_mode", PROCESS_MODE_PAUSABLE)
	tree.set_group_flags(2, "tile", "process_mode", PROCESS_MODE_PAUSABLE)
	tree.set_group_flags(2, "item", "process_mode", PROCESS_MODE_PAUSABLE)
	tree.set_group_flags(2, "event", "process_mode", PROCESS_MODE_PAUSABLE)
	tree.set_group_flags(2, "time_immune", "process_mode", PROCESS_MODE_PAUSABLE)
	
	match ps:
		PauseState.NORMAL:
			pause_tiles(false)
			tree.paused = false
			entity_active = true
		PauseState.PAUSED:
			pause_tiles(true)
			tree.set_group_flags(2, "views", "process_mode", PROCESS_MODE_PAUSABLE)
			tree.paused = true
			entity_active = false
		PauseState.TRANSITION:
			pause_tiles(false)
			tree.set_group_flags(2, "view", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "player", "process_mode", PROCESS_MODE_ALWAYS)
			#tree.set_group_flags(2, "movement", "process_mode", PROCESS_MODE_PAUSABLE)
			tree.set_group_flags(2, "entity", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "event", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "tile", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "item", "process_mode", PROCESS_MODE_ALWAYS)
			if Global.current_room_control.has_player:
				get_player().get_node("Movement").movement_input = Vector2.ZERO
			tree.paused = true
			entity_active = false
		PauseState.EVENT:
			pause_tiles(false)
			tree.set_group_flags(2, "view", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "player", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "entity", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "event", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "tile", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "item", "process_mode", PROCESS_MODE_ALWAYS)
			tree.set_group_flags(2, "time_immune", "process_mode", PROCESS_MODE_ALWAYS)
			if Global.current_room_control.has_player:
				get_player().get_node("Movement").movement_input = Vector2.ZERO
			tree.paused = true
			entity_active = false
		PauseState.TIME_PAUSED:
			pause_tiles(true)
			tree.set_group_flags(2, "views", "process_mode", PROCESS_MODE_PAUSABLE)
			tree.set_group_flags(2, "time_immune", "process_mode", PROCESS_MODE_ALWAYS)
			tree.paused = true
			entity_active = false
		PauseState.HITLAG:
			tree.set_group_flags(2, "view", "process_mode", PROCESS_MODE_PAUSABLE)
			tree.paused = true
			entity_active = false

func pause_tiles(pause := true) -> void:
	for tm in get_tree().get_nodes_in_group("atilemap"):
		if tm is TileMap:
			var ts = tm.tile_set
			for t in ts.get_tiles_ids():
				var tinfo = ts.tile_get_texture(t)
				if tinfo is AnimatedTexture:
					tinfo.pause = pause
					ts.tile_set_texture(t, tinfo)
