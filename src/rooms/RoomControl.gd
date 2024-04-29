class_name RoomControl
extends Node2D

@export var has_player: bool = true
@export var uses_camera: bool = true
@export var has_menu: bool = true
@export var scene_path: String = ""

var dir = "src/rooms/"
var ext = ".tscn"
var music_started := false
var music_fading := -1.0
var music_autofade := false
var music_to_play := "Music"

signal fade_over(out)

func _ready():
	Global.gui.connect("fade_finished",Callable(self,"fadetimer_over"))
	Global.gui.fade_screen(false)
	
	Global.current_room = get_parent()
	Global.current_room_control = self
	Global.current_room_path = scene_path
	Global.current_tilemaps.clear()
	Global.player_x_offset = 0
	Global.player_y_offset = 0
	
	Global.set_pause_state(Global.PauseState.TRANSITION)
	#Global.set_pause_state(Global.PauseState.NORMAL)
	#Global.gui.get_node("Menu").lock_input = false
	
	if has_player:
		Global.get_player().get_node("Movement").facing = Stats.player_direction
		
		if Global.saved_room_entrance != "" and Global.new_room_entrance == "":
			Global.new_room_entrance = Global.saved_room_entrance
			Global.saved_room_entrance = ""
		if Global.new_room_entrance != "":
			for w in get_tree().get_nodes_in_group("warp"):
				if w.entrance_name == Global.new_room_entrance:
					w.move_player()
					Stats.set_stat(Stats.Data.entrance, w.entrance_id)
					break
		elif scene_path == Stats.rooms[Stats.get_stat(Stats.Data.room)] and Stats.get_stat(Stats.Data.entrance) != 0:
			for w in get_tree().get_nodes_in_group("warp"):
				if w.entrance_id == Stats.get_stat(Stats.Data.entrance):
					w.move_player()
					break
		
		Global.player_x = 0
		Global.player_y = 0
	
	#if has_player:
	#	var i = 0
	#	for r in Stats.rooms:
	#		if r == scene_path:
	#			Stats.game_data[Stats.Data.room] = i
	#			DataManager.data_save(Stats.file_slot)
	#		i += 1
			
	Global.new_room_entrance = ""
	
	reready()

func reready():
	Global.gui.global_position = Vector2.ZERO
	get_viewport().canvas_transform.origin = Vector2.ZERO
	
func _process(delta):
	if music_fading != -1:
		var game_music = SceneManager.game_view.get_node("Music")
		if game_music.playing:
			if music_autofade:
				music_fading -= 0.01
			if music_fading > 0:
				change_music_vol()
			else:
				game_music.playing = false
				music_autofade = false
				Stats.set_setting(Stats.Settings.music_vol)
		else:
			music_fading = -1
			
func change_music_vol():
	var val = music_fading
	if val == -1:
		val = 1
	Stats.set_setting(Stats.Settings.music_vol, Stats.game_settings[Stats.Settings.music_vol] * val, false)

func room_restart(from_save = false):
	#Global.start_from_save = from_save
	
	room_change(Global.current_room_path)
	
func room_return():
	if Global.saved_room_path != "":
		room_change(Global.saved_room_path, true)
	
func room_change(path, preserve_entrance = false):
	if !SceneManager.find_scene(path):
		room_change("misc/invalid")
		return
	
	if !preserve_entrance:
		Global.saved_room_entrance = ""
		
	Global.set_pause_state(Global.PauseState.TRANSITION)
	if has_player:
		Global.get_player().get_node("PlayerControls").fade_buffer = true
	fadeout()
	await Global.gui.fade_finished
	room_end()
	
	SceneManager.load_scene(path)
	
func room_change_from_data():
	if Stats.get_stat(Stats.Data.room) < Stats.rooms.size():
		room_change(Stats.rooms[Stats.get_stat(Stats.Data.room)])
	else:
		room_change("misc/invalid")
	
func game_end():
	fadeout()
	await Global.gui.fade_finished
	room_end()
	get_tree().quit()
	
func room_end():
	InputActions.buffered_inputs.clear()
	
	if Global.current_room == get_parent():
		Global.current_room = null
		Global.current_room_control = null
		#Global.override_boundary_assign = true
		
	if has_player:
		Stats.player_direction = Global.get_player().get_node("Movement").facing
		
func play_music(trackname):
	var n = get_node_or_null(trackname)
	if n and n.stream:
		set_music(trackname)
		var game_music = SceneManager.game_view.get_node("Music")
		if !game_music.playing:
			game_music.playing = true

func set_music(trackname):
	music_fading = -1
	Stats.set_setting(Stats.Settings.music_vol)
	var n = get_node_or_null(trackname)
	if n and n.stream:
		var game_music = SceneManager.game_view.get_node("Music")
		if !game_music.stream or game_music.stream.data != n.stream.data:
			game_music.stream = n.stream
			game_music.playing = false
	else:
		var game_music = SceneManager.game_view.get_node("Music")
		game_music.stream = null
		game_music.playing = false
			
func stop_music():
	var game_music = SceneManager.game_view.get_node("Music")
	game_music.playing = false
	music_fading = -1
	Stats.set_setting(Stats.Settings.music_vol)
	
func fade_music():
	music_fading = 1
	music_autofade = true
		
func fadeout():
	Global.gui.fade_screen()

func fadetimer_over(out):
	if !out and !music_started:
		if SceneManager.game_view:
			play_music(music_to_play)
			music_started = true
		#$Music.playing = true
	if has_player:
		Global.get_player().get_node("PlayerControls").fade_buffer = false
	emit_signal("fade_over", out)
	if !out and Global.current_pausestate == Global.PauseState.TRANSITION:
		Global.set_pause_state(Global.PauseState.NORMAL)
		
func _exit_tree():
	DataManager.window_save()


func _on_Timer_timeout():
	set_music(music_to_play)
