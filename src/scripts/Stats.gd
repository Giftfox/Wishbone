extends Node

enum Settings {
	screen_size,
	show_fps,
	master_vol,
	music_vol,
	sfx_vol,
	default_file,
	gamepad_type,
	vibration,
	show_inputs,
	
	sfx_display = 20,
	music_display,
	no_shake,
	shoot_toggle,
	filter,
	visual_fx,
	scary,
	clock,
	flashing,
	outline,
	repetitive_sfx,
	
	infinite_hp,
	free_items,
	extra_hover,
	easyboss,
	no_pits,
	timer_extend,
	
	fps_cap,
	
	knockback,
	spikes,
	
	keybinds = 40,
	keybinds_end = 80,
	
	movement_type = 90,
	disable_stick,
	
	length = 150
}

enum Data {
	version,
	
	room,
	entrance,
	
	flags = 100
}

var rooms = [
	"misc/hub",
	"misc/debug2",
	"misc/moon",
	"misc/shizukanroom"
]

signal screen_set()
signal items_changed()
signal entity_deployed()

const data_version = 0

var key_ids = [
	[
		0, KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_A, KEY_A, KEY_A, KEY_A, KEY_A, KEY_A, KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I, KEY_J, KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z,
		KEY_PERIOD, KEY_COMMA, KEY_SLASH, KEY_SPACE, KEY_BRACKETLEFT, KEY_BRACKETRIGHT, KEY_BACKSLASH, KEY_BACKSPACE, KEY_SEMICOLON, KEY_APOSTROPHE, KEY_SHIFT, KEY_CTRL
	],
	[]
]
var button_ids = [
	[
		0, JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER
	],
	[]
]
var action_ids = ["menu_accept", "menu_cancel"]

var keynames = {
	KEY_0: "0",
	KEY_1: "1",
	KEY_2: "2",
	KEY_3: "3",
	KEY_4: "4",
	KEY_5: "5",
	KEY_6: "6",
	KEY_7: "7",
	KEY_8: "8",
	KEY_9: "9",
	KEY_A: "A",
	KEY_B: "B",
	KEY_C: "C",
	KEY_D: "D",
	KEY_E: "E",
	KEY_F: "F",
	KEY_G: "G",
	KEY_H: "H",
	KEY_I: "I",
	KEY_J: "J",
	KEY_K: "K",
	KEY_L: "L",
	KEY_M: "M",
	KEY_N: "N",
	KEY_O: "O",
	KEY_P: "P",
	KEY_Q: "Q",
	KEY_R: "R",
	KEY_S: "S",
	KEY_T: "T",
	KEY_U: "U",
	KEY_V: "V",
	KEY_W: "W",
	KEY_X: "X",
	KEY_Y: "Y",
	KEY_Z: "Z",
	KEY_PERIOD: ".",
	KEY_COMMA: ",",
	KEY_SLASH: "/",
	KEY_SPACE: "Sp",
	KEY_BRACKETLEFT: "[",
	KEY_BRACKETRIGHT: "]",
	KEY_BACKSLASH: "\\",
	KEY_BACKSPACE: "Bak",
	KEY_SEMICOLON: ";",
	KEY_APOSTROPHE: "'",
	KEY_ESCAPE: "Esc",
	KEY_SHIFT: "Shift",
	KEY_CTRL: "Ctrl"
}

var xp := 0.0
var hp := 100.0
var hp_max := 100.0
var stamina := 100.0
var stamina_max := 100.0
var hunger := 100.0
var hunger_max := 100.0
var player_direction = Global.Dirs.DOWN
var day := 1
var saved_days := 0

var items := []
var crafted := []
var previously_deployed_entities := []
var saved_nav_spots := []
var loop := 0.0

var current_map_grid := "hub"

var file_slot := 0

var game_data : Array = []
var game_settings : Array = []

var map_node
var log_node
var popup_node

func _ready():
	for i in range(key_ids[0].size()):
		key_ids[1].append(i)
		
	DataManager.data_load()
	DataManager.settings_load()
	DataManager.window_load()

func _process(delta):
	#if Global.current_pausestate == Global.PauseState.NORMAL and Input.is_action_just_pressed("menu_menu"):
		#Global.gui.get_node("MenuController").set_active_menu("PauseMenu")
		#Global.set_pause_state(Global.PauseState.PAUSED)
	
	hp = clamp(hp, 0, hp_max)
	
	if Input.is_action_just_pressed("menu_scale"):
		set_setting(Settings.screen_size, Global.shift_index(game_settings[Settings.screen_size], 1, 2, 1), true)
		DataManager.settings_save()
	if Input.is_action_just_pressed("debug_2"):
		set_setting(Settings.show_fps, Global.shift_index(game_settings[Settings.show_fps], 0, 1, 1), true)
		DataManager.settings_save()

func set_flag(flag, ind = 1):
	game_data[Data.flags + flag] = ind
	
func get_flag(flag):
	return game_data[Data.flags + flag]

func initialize_data_array():
	game_data.clear()
	while game_data.size() < 4000:
		game_data.append(0)

func initialize_data():
	initialize_data_array()
	
	game_data[Data.version] = data_version
	
	xp = 0
	
	hp_max = 100
	hp = hp_max
	
	stamina_max = 100
	stamina = stamina_max
	
func initialize_settings():
	game_settings.clear()
	while game_settings.size() < 100:
		game_settings.append(0)
		
	game_settings[Settings.screen_size] = 1
	game_settings[Settings.show_fps] = 0
	game_settings[Settings.music_vol] = 8
	game_settings[Settings.sfx_vol] = 8
	
	initialize_keybinds()
	set_all_settings()
	
func initialize_keybinds():
	set_keybind("menu_accept", [KEY_Z, KEY_SPACE, 0, 0])
	set_keybind("menu_cancel", [KEY_X, KEY_BACKSPACE, 0, 0])

func set_setting(setting, val = null, set_in_data = true):
	if val != null and set_in_data:
		game_settings[setting] = val
	if !val:
		val = game_settings[setting]
	
	match setting:
		Settings.screen_size:
			temp_set_screen()
		Settings.master_vol:
			set_volume(AudioServer.get_bus_index("Master"), val)
		Settings.music_vol:
			set_volume(AudioServer.get_bus_index("Music"), val)
		Settings.sfx_vol:
			set_volume(AudioServer.get_bus_index("SFX"), val)
		Settings.keybinds:
			var i = 0
			while i < Settings.keybinds_end and floor(i / 4) < action_ids.size():
				var keylist = []
				for j in range(4):
					keylist.append(key_ids[0][key_ids[1].find(game_settings[Settings.keybinds + i + j])])
				set_keybind(action_ids[floor(i / 4)], keylist)
				i += 4
		Settings.fps_cap:
			match val:
				0: Engine.max_fps = 60
				1: Engine.max_fps = 30
				

func set_keybind(action_id, keys = []):
	var events = InputMap.action_get_events(action_id)
	
	events.clear()
	for i in range(2):
		if keys[i] != 0:
			var e = InputEventKey.new()
			e.keycode = keys[i]
			events.append(e)
		game_settings[Settings.keybinds + action_ids.find(action_id) * 4 + i] = key_ids[1][key_ids[0].find(keys[i])]
	
	# Replace events in action
	InputMap.action_erase_events(action_id)
	for e in events:
		InputMap.action_add_event(action_id, e)

func set_volume(bus, volume):
	var amp = float(volume) / 10.0
	amp = Global.scale_range_to(amp, 0.000001, 1)
	var db = (log(amp) / log(10)) * 20

	AudioServer.set_bus_volume_db(bus, db)
	AudioServer.set_bus_mute(bus, volume == 0)

func set_all_settings():
	var i = 0
	for s in game_settings:
		set_setting(i)
		i += 1

func temp_set_screen() -> void:
	game_settings[Settings.screen_size] = clamp(game_settings[Settings.screen_size], 1, 2)
	if game_settings[Settings.screen_size] == 2:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		var real_scale = game_settings[Settings.screen_size] * 0.5
		var wsize = DisplayServer.window_get_size()
		DisplayServer.window_set_size(Vector2(real_scale * Global.VIEW_SIZE.x * Global.WINDOW_SCALE, real_scale * Global.VIEW_SIZE.y * Global.WINDOW_SCALE))
		#if wsize != OS.get_window_size():
		#	OS.set_window_position(OS.get_screen_size(OS.get_current_screen()) * 0.5 - OS.get_window_size() * 0.5)
	emit_signal("screen_set")
	
func add_item(item, increase):
	set_item(item, get_item_quantity(item) + increase)
	
func set_item(item, quantity):
	if quantity == 0:
		for i in items:
			if i[0] == item:
				items.erase(i)
	else:
		var success = false
		for i in items:
			if i[0] == item:
				i[1] = quantity
				success = true
				break
		if !success:
			items.append([item, quantity])
			
	emit_signal("items_changed")
			
func deploy_entity(en):
	if !previously_deployed_entities.has(en):
			previously_deployed_entities.append(en)
	emit_signal("entity_deployed")
			
func get_item_quantity(item):
	for i in items:
		if i[0] == item:
			return i[1]
	return 0

func add_stat(stat: Data, val: int):
	game_data[stat] += val

func set_stat(stat: Data, val: int):
	game_data[stat] = val
	
func get_stat(stat: Data):
	return game_data[stat]

func set_stat_array(stat_start: Data, stat_end: Data, arr: Array):
	stat_clear_range(stat_start, stat_end)
	for j in range(arr.size()):
		var val = arr[j]
		if val < 0:
			val += 256
		Stats.game_data[stat_start + j] = val

func stat_clear_range(stat_start: Data, stat_end: Data):
	var i = stat_start
	while i < stat_end:
		Stats.game_data[i] = 0
		i += 1

func set_vars_array(stat_start: Data, stat_end: Data, arr: Array, clear = true, top_threshold = 250):
	if clear:
		arr.clear()
	var i = stat_start
	while i < stat_end:
		var val = Stats.game_data[i]
		if val > top_threshold:
			val -= 256
		if clear and i < arr.size():
			arr[i] = val
		else:
			arr.append(val)
		i += 1
