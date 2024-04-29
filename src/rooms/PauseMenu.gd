extends Menu

var index := 0
var setting_index := -1
var setting_saved_val := 0

var binding_key := ""
var binding_index := 0
var last_action_is_button := false
var bind_list = [[["menu_accept", "Interact"], ["menu_cancel", "Cancel"]], [["game_spell", "Cast spell" ], ["game_walk", "Walk"]], [["game_spell_switch_left", "Left spell"], ["game_spell_switch_right", "Right spell"]]]

func _ready():
	box_resource = preload("res://src/parts/PauseBox.tscn")
	
func _input(event):
	if event is InputEventKey:
		last_action_is_button = false
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_action_is_button = true
		
	if binding_key != "":
		# Change keybind
		if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
			if (event is InputEventKey and (Stats.key_ids[0].has(event.scancode) or event.scancode == KEY_ESCAPE)):
				# Get current input events
				var events = InputMap.action_get_events(binding_key)
				var key_events = []
				var button_events = []
				for e in events:
					if e is InputEventKey:
						key_events.append(e)
					else:
						button_events.append(e)
				
				# Locate and change correct event
				if event is InputEventKey:
					events = key_events
				else:
					events = button_events
					
				if events.size() <= binding_index:
					events.append(event)
				else:
					events[binding_index] = event
					
				if event is InputEventKey:
					if event.scancode == KEY_ESCAPE:
						events.remove_at(binding_index)
					
				# Replace events in action
				InputMap.action_erase_events(binding_key)
				for e in key_events:
					InputMap.action_add_event(binding_key, e)
				for e in button_events:
					InputMap.action_add_event(binding_key, e)
					
				for i in range(2):
					if key_events.size() > i:
						Stats.game_settings[Stats.Settings.keybinds + 4 * Stats.action_ids.find(binding_key) + i] = Stats.key_ids[1][Stats.key_ids[0].find(key_events[i].scancode)]
						
				DataManager.settings_save()
				
				binding_key = ""
				input_buffer = true
				$KeybindTimer.stop()
				get_parent().get_node("SFX").play_sfx("confirm")
	
func _process(delta):
	if !input_buffer:
		if index == 1 and setting_index != -1:
			var unchecked := 0
			var moveRight = 1 if Input.is_action_just_pressed("menu_right") else 0
			var moveLeft = 1 if Input.is_action_just_pressed("menu_left") else 0
			unchecked = moveRight - moveLeft
			if unchecked != 0:
				get_parent().get_node("SFX").play_sfx("shift")
				var maxval = 0
				var minval = 0
				match setting_index:
					Stats.Settings.music_vol, Stats.Settings.sfx_vol:
						maxval = 10
						minval = 0
					Stats.Settings.show_fps:
						maxval = 1
						minval = 0
					Stats.Settings.screen_size:
						maxval = 3
						minval = 1
				Stats.game_settings[setting_index] = Global.shift_index(Stats.game_settings[setting_index], minval, maxval, unchecked)
				Stats.set_setting(setting_index, Stats.game_settings[setting_index], true)
	
func can_switch():
	if input_buffer or setting_index != -1 or binding_key != "":
		return false
	return true
	
func draw_boxes():
	match index:
		0:
			grid_size = Vector2(1, 4)
		1:
			grid_size = Vector2(2, 3)
		2:
			grid_size = Vector2(1, 3)
		3:
			grid_size = Vector2(2, 3)
	super.draw_boxes()
	
	match index:
		0, 2:
			$SelectionBox.position = Vector2(432, 40 + grid_pos.y * 88)
		1, 3:
			$SelectionBox.position = Vector2(200 + 232 * grid_pos.x, 40 + grid_pos.y * 88)
			
	for i in range(10):
		for j in range (4):
			var box_name = "Box_" + str(j) + "_" + str(i)
			var box = get_node_or_null(box_name)
			if box:
				if j > grid_size.x - 1 or i > grid_size.y - 1:
					box.visible = false

func draw_box(pos = Vector2.ZERO):
	var box = super.draw_box(pos)
	if box:
		box.visible = true
		box.get_node("ShadedLabel").position = Vector2(30, 20)
		match index:
			# Main
			0:
				box.position = Vector2(432, 40 + 88 * pos.y)
				if pos.y == 0:
					box.get_node("ShadedLabel").text = "Resume"
				if pos.y == 1:
					box.get_node("ShadedLabel").text = "Settings"
				if pos.y == 2:
					box.get_node("ShadedLabel").text = "Quit"
				if pos.y == 3:
					box.get_node("ShadedLabel").text = "Warp home"
			# Settings
			1:
				box.position = Vector2(200 + 232 * pos.x, 40 + 88 * pos.y)
				if pos == Vector2(0, 0):
					box.get_node("ShadedLabel").text = "Music: " + str(Stats.game_settings[Stats.Settings.music_vol])
				if pos == Vector2(1, 0):
					box.get_node("ShadedLabel").text = "Sfx: " + str(Stats.game_settings[Stats.Settings.sfx_vol])
				if pos == Vector2(0, 1):
					box.get_node("ShadedLabel").text = "Scale: "
					if Stats.game_settings[Stats.Settings.screen_size] < 3:
						box.get_node("ShadedLabel").text += str(Stats.game_settings[Stats.Settings.screen_size]) + "x"
					elif Stats.game_settings[Stats.Settings.screen_size] == 3:
						box.get_node("ShadedLabel").position.x = 15
						box.get_node("ShadedLabel").text += "Fullscreen"
				if pos == Vector2(1, 1):
					box.get_node("ShadedLabel").text = "Fps: "
					if Stats.game_settings[Stats.Settings.show_fps] == 1:
						box.get_node("ShadedLabel").text += "On"
					else:
						box.get_node("ShadedLabel").text += "Off"
				if pos == Vector2(0, 2):
					box.get_node("ShadedLabel").text = "Controls"
				if pos == Vector2(1, 2):
					box.get_node("ShadedLabel").text = "Back"
					
				if pos == grid_pos and setting_index != -1:
					box.get_node("ShadedLabel").modulate = Color(1, 0, 0)
				else:
					box.get_node("ShadedLabel").modulate = Color(1, 1, 1)
			# Quit
			2:
				box.position = Vector2(432, 40 + 88 * pos.y)
				if pos.y == 0:
					box.get_node("ShadedLabel").text = "Back"
				if pos.y == 1:
					box.get_node("ShadedLabel").text = "Reset"
				if pos.y == 2:
					box.get_node("ShadedLabel").text = "Quit!!"
			3:
				box.position = Vector2(200 + 232 * pos.x, 40 + 88 * pos.y)
				box.get_node("ShadedLabel").position = Vector2(30, 10)
				box.get_node("ShadedLabel").text = bind_list[pos.y][pos.x][1]
				
				var txt = "<None>"
				var events = InputMap.action_get_events(bind_list[pos.y][pos.x][0])
				var key_events = []
				var button_events = []
				for e in events:
					if e is InputEventKey:
						key_events.append(e.as_text())
					elif e is InputEventJoypadButton:
						button_events.append(e.button_index)
					elif e is InputEventJoypadMotion:
						button_events.append(e.axis)
				if last_action_is_button:
					events = button_events
				else:
					events = key_events
				
				if events.size() > 0:
					txt = "<" + str(events[0]) + ">"
				
				if binding_key == bind_list[pos.y][pos.x][0]:
					txt = "<.....>"
				
				box.get_node("ShadedLabel").text += "\n" + txt
					
func menu_input(type: String):
	if !input_buffer:
		if type == "confirm":
			match index:
				# Main
				0:
					if grid_pos.y == 0:
						Global.gui.get_node("MenuController").end_menu()
						return "cancel"
					if grid_pos.y == 1:
						index = 1
						grid_pos = Vector2.ZERO
						return "confirm"
					if grid_pos.y == 2:
						index = 2
						grid_pos = Vector2.ZERO
						return "confirm"
					if grid_pos.y == 3:
						Event.run_event(61)
						return "confirm"
				# Settings
				1:
					if setting_index == -1:
						match grid_pos:
							Vector2(0, 0):
								setting_index = Stats.Settings.music_vol
							Vector2(1, 0):
								setting_index = Stats.Settings.sfx_vol
							Vector2(0, 1):
								setting_index = Stats.Settings.screen_size
							Vector2(1, 1):
								setting_index = Stats.Settings.show_fps
							Vector2(0, 2):
								index = 3
								grid_pos = Vector2.ZERO
							Vector2(1, 2):
								index = 0
								grid_pos = Vector2(0, 1)
						if setting_index != -1:
							setting_saved_val = Stats.game_settings[setting_index]
						return "confirm"
					else:
						setting_index = -1
						setting_saved_val = -1
						DataManager.settings_save()
						return "confirm"
				# Main
				2:
					if grid_pos.y == 0:
						index = 0
						grid_pos = Vector2(0, 2)
						return "cancel"
					elif grid_pos.y == 1:
						Event.run_event(80)
						return "confirm"
					elif grid_pos.y == 2:
						Event.run_event(81)
						return "confirm"
				3:
					if binding_key == "":
						binding_key = bind_list[grid_pos.y][grid_pos.x][0]
						$KeybindTimer.start()
						return "confirm"
							
		if type == "cancel":
			match index:
				0:
					Global.gui.get_node("MenuController").end_menu()
					return "cancel"
				1:
					if setting_index != -1:
						Stats.set_setting(setting_index, setting_saved_val, true)
						setting_index = -1
						setting_saved_val = 0
					else:
						index = 0
						grid_pos = Vector2(0, 1)
					return "cancel"
				2:
					index = 0
					grid_pos = Vector2(0, 2)
					return "cancel"
				3:
					if binding_key == "":
						index = 1
						grid_pos = Vector2(0, 2)
						return "cancel"
		if type == "menu":
			if binding_key == "" and setting_index == -1:
				index = 0
				Global.gui.get_node("MenuController").end_menu()
				return "cancel"
	return ""

func _on_KeybindTimer_timeout():
	binding_key = ""
