extends Node

var current_event := 0
var current_source

var vn_handler
var choice_handler

var step := 0
var step_advance := false
var skipping := false
var skip_buffer := false
var queue_skip := false
var dialogue_step := 0
var dialogue_advance := false

var saved_dialogue_info := []
var auto_event_complete := false
var room_changed := false

enum Common {
	end_dialogue = 10,
	end_dialogue_no_state_change = 11
}

enum vn_actions {
	portrait_new,
	portrait_change_type,
	portrait_change_variants,
	portrait_change_facing,
	portrait_move,
	portrait_slide,
	portrait_refresh,
	portrait_clear,
	
	dialogue_new,
	dialogue_clear,
	dialogue_clear_all,
	
	illustration_new,
	illustration_clear_category,
	illustration_clear_all
}
var vn_action_functions = {
	vn_actions.portrait_new: "vn_portrait_create",
	vn_actions.dialogue_new: "vn_dialogue_create",
	vn_actions.illustration_new: "vn_illustration_create",
	vn_actions.portrait_change_type: "vn_portrait_newtype",
	vn_actions.portrait_change_variants: "vn_portrait_newvariants",
	vn_actions.portrait_change_facing: "vn_portrait_face",
	vn_actions.portrait_move: "vn_portrait_newpos",
	vn_actions.portrait_slide: "vn_portrait_slide",
	vn_actions.portrait_refresh: "vn_portrait_refresh",
	vn_actions.portrait_clear: "vn_portrait_clear",
	vn_actions.dialogue_clear: "vn_dialogue_clear",
	vn_actions.dialogue_clear_all: "vn_dialogue_clear_all",
	vn_actions.illustration_clear_category: "vn_illustration_clear_category",
	vn_actions.illustration_clear_all: "vn_illustration_clear_all",
}

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	
func _process(delta):
	if current_event != 0:
		#if !skip_buffer:
		#	if Global.current_room_control.room_loaded and Input.is_action_pressed("menu_menu"):
		#		if !skipping:
		#			skipping = true
		#			SceneManager.game_view.get_node("EventSkipTimer").start()
		#		elif skipping and SceneManager.game_view.get_node("EventSkipTimer").is_stopped():
		#			queue_skip = true
		#			#skip_buffer = true
		#	else:
		#		skipping = false
		#else:
		#	skipping = false
		#	if !Input.is_action_pressed("menu_menu"):
		#		skip_buffer = false
			
		run_event(current_event, current_source)
		queue_skip = false
	else:
		step = 0
		step_advance = false
		dialogue_step = 0
		dialogue_advance = false
		saved_dialogue_info = []
		auto_event_complete = false
		room_changed = false
		
	if Input.is_action_just_pressed("debug_1"):
		run_event(112)
	
func end_event(set_state = true):
	if set_state:
		if Global.current_pausestate == Global.PauseState.EVENT:
			Global.set_pause_state(Global.PauseState.NORMAL)
		vn_handler.end_cutscene()
	current_event = 0
	step = 0
	step_advance = false
	dialogue_step = 0
	dialogue_advance = false
	room_changed = false
		
func run_event(event, source = null, override = false):
	if event == 0:
		return false
	
	if current_event != 0 and current_event != event and !override:
		return false
		
	var timer = SceneManager.game_view.get_node("EventTimer")
	if step_advance and timer.is_stopped():
		step += 1
		step_advance = false
	if dialogue_advance and timer.is_stopped():
		dialogue_step += 1
		dialogue_advance = false
	
	#var player
	#if Global.get_player():
	#	player = Global.get_player().get_node("EventHandler")
		
	current_event = event
	current_source = source
	
	var dialogue = Global.gui.get_node("HUD/DialogueBox")
		
	match event:
		100:
			if vn_handler:
				if !step_advance:
					match step:
						0:
							vn_handler.spawn_illustration("wall")
							vn_handler.spawn_portrait(100, "bel_cross")
							vn_handler.spawn_portrait(200, "andre_angry", false, 0)
							timer.start(1)
							step_advance = true
						1:
							vn_handler.spawn_dialogue(100, 100, "blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah", true, -1, -1)
							step_advance = true
						2:
							if Input.is_action_just_pressed("menu_accept"):
								step_advance = true
						3:
							vn_handler.get_dialogue(100).clear()
							vn_handler.get_portrait(100).set_variants([1])
							vn_handler.get_portrait(200).set_variants(["face_angry"], ["face_wink"])
							vn_handler.spawn_dialogue(200, 200, "Stop talking, your dialogue is obscuring me.")
							step_advance = true
						4:
							if Input.is_action_just_pressed("menu_accept"):
								step_advance = true
						5:
							vn_handler.get_dialogue(200).clear()
							vn_handler.spawn_dialogue(100, 101, "blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah", true, -1, -1)
							timer.start(1)
							step_advance = true
						6:
							var dia = vn_handler.spawn_dialogue(200, 201, "", true, -1, 0, Vector2(20, 0))
							dia.z_index = 0
							dia.get_node("Fill/Animation").play("andre_stop")
							vn_handler.get_portrait(200).set_variants(["bg1"], ["bg0"])
							step_advance = true
						7:
							if Input.is_action_just_pressed("menu_accept"):
								step_advance = true
						8:
							vn_handler.end_cutscene()
							current_event = 0
							step = 0
							
		110:
			match step:
				0:
					event_vn_dialogue([
						[
							[
								[vn_actions.portrait_new, [100, "novis"]], [vn_actions.portrait_new, [200, "novis", true, -1]]
							],
							0.5, true
						],
						[
							[
								[vn_actions.dialogue_new, [100, 100, "Me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me"]]
							],
							0.0, true
						],
						[
							[[vn_actions.dialogue_new, [200, 200, "Me (on the right side)"]]],
							0.0, true
						],
						[
							[[vn_actions.dialogue_clear_all, []]],
							0.1, false
						]
					])
				1:
					choice_handler.create_choices(["Choice 1", "Choice 2 Choice 2 Choice 2 Choice 2 Choice 2"])
					step_advance = true
				2:
					if choice_handler.picked:
						choice_handler.finish()
						step_advance = true
				3:
						if choice_handler.selection == 0:
							event_vn_dialogue([
								[
									[[vn_actions.dialogue_new, [100, 100, "Wow wow wow wow"]]],
									0.0, true
								]
							])
						if choice_handler.selection == 1:
							event_vn_dialogue([
								[
									[[vn_actions.dialogue_new, [200, 200, "Wow!!!"]]],
									0.0, true
								],
								[
									[[vn_actions.dialogue_clear_all, []], [vn_actions.dialogue_new, [200, 300, "Wow!!!", "rectangle"]]],
									0.0, true
								],
								[
									[[vn_actions.dialogue_new, [100, 300, "Wow!!!!!!!!!", "rectangle"]]],
									0.0, true
								],
							])
				4:
					event_vn_dialogue([
						[
							[[vn_actions.dialogue_clear_all, []]],
							0.5, false
						]
					], true)
					
		111:
			event_vn_dialogue([
						[
							[
								[vn_actions.portrait_new, [100, "shizukan"]], [vn_actions.portrait_new, [200, "novis", true, -1]]
							],
							0.5, true
						],
						[
							[
								[vn_actions.dialogue_new, [100, 100, "...", "rectangle"]]
							],
							0.0, true
						],
						[
							[
								[vn_actions.dialogue_clear_all, []], [vn_actions.dialogue_new, [200, 200, "Me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me me"]]
							],
							0.0, true
						],
						[
							[
								[vn_actions.dialogue_clear_all, []],
								[vn_actions.portrait_change_variants, [100, ["Annoyed"], []]],
								[vn_actions.dialogue_new, [100, 300, "...", "rectangle"]]
							],
							0.0, true
						],
						[
							[[vn_actions.dialogue_clear_all, []]],
							0.1, false
						]
					], true)
					
		112:
			event_vn_dialogue([
						[
							[
								[vn_actions.portrait_new, [100, "shizukan"]], [vn_actions.portrait_new, [200, "nyaofa", true, -1]]
							],
							0.5, true
						],
						[
							[
								[vn_actions.dialogue_new, [100, 100, "...", "rectangle"]]
							],
							0.0, true
						],
						[
							[
								[vn_actions.dialogue_clear_all, []], [vn_actions.dialogue_new, [200, 200, "Meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow", "rectangle"]]
							],
							0.0, true
						],
						[
							[
								[vn_actions.dialogue_clear_all, []],
								[vn_actions.dialogue_new, [100, 300, "...", "rectangle"]]
							],
							0.0, true
						],
						[
							[[vn_actions.dialogue_clear_all, []]],
							0.1, false
						]
					], true)
							
		120:
			event_vn_dialogue([
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_1"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_2"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_3"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_4"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_5"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_6"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_6a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_6b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_7"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_7a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_8"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_9"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_10"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_11"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_11a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_11b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_12"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_13"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_14"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_15"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_16"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_16a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_17"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_17b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_18"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_18a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_19"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_20"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_21"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_22"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_23"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_24"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_25"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_26"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_26a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_27"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_28"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_29"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_30"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_31"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_32"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_33"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_34"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_35"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_36"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_37"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_38"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_39"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_40"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_41"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_42"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_42a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_43"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_44"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_45"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_46"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_47"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_48"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_49"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_50"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_51"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["nuez", "", "nuez_52"]] ], 0.0, true],
				[
					[[vn_actions.illustration_clear_all, []]],
					0.0, true
				]
			], true)
			
		130:
			event_vn_dialogue([
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "1"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "2"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "3"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "4"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "5"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "6"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "7"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "8"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "9"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "10"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "10a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "11"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "11a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "11b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "12"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "12a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "12b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "12c"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "13"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "14"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "14a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "14b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "14c"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "15"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "16"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "16a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "17"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "17a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "17b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "17c"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "18"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "19"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "20"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "20a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "21"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "22"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "23"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "24"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "25"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "25a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "25b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "26"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "27"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "28"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "29"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "29a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "29b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "29c"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "29d"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "30"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "30a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "30b"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "31"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "32"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "32a"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "33"]] ], 0.0, true],
				[ [ [vn_actions.illustration_new, ["alqo_visit", "", "34"]] ], 0.0, true],
				[
					[[vn_actions.illustration_clear_all, []]],
					0.0, true
				]
			], true)
					
		200:
			event_dialogue(dialogue, [["Hi! I'm Info Bunny.", true], \
			[" I'm here to help out before you start adventuring.", false], \
			["You're not in any danger in this area. We call this place the \"Dawn\".", true], \
			["I put up a bunch of notes around here! Feel free to read them, and explore and try things out.", true], \
			["Go through the north path when you're ready to start your adventure!", true]])
						
		_:
			return false
	return true

func event_single_dialogue(dialogue, txt = ""):
	event_dialogue(dialogue, [[txt, true]])
				
# txt: [text (string), new box (bool)]
func event_dialogue(dialogue, txt = []):
	if !step_advance:
		var success = false
		for i in range(txt.size()):
			if step == i:
				if i == 0:
					Global.set_pause_state(Global.PauseState.EVENT)
				if i == 0 or dialogue_advance:
					if txt[i][1]:
						dialogue.start_message(txt[i][0])
					else:
						dialogue.continue_message(txt[i][0])
					step_advance = true
				success = true
		if !success and dialogue_advance:
			dialogue.end_message()
			Global.set_pause_state(Global.PauseState.NORMAL)
			current_event = 0
			step = 0
			
# [actions_set[actions[name, arguments[]], timer(float), input(bool)]]
func event_vn_dialogue(txt, complete = false, step_offset = 0):
	var timer = SceneManager.game_view.get_node("EventTimer")
	
	if !dialogue_advance and vn_handler.prepped:
		var finished = false
		for i in range(txt.size() + 1):
			if dialogue_step - step_offset == i:
				if i == 0:
					Global.set_pause_state(Global.PauseState.EVENT)
				var pressed = false
				for input in ["menu_accept", "menu_cancel", "game_jump"]:
					if Input.is_action_just_pressed(input):
						pressed = true
						break
						
				# Once input is given, or the timer runs out, load the actions for the current step and queue the next one
				if i == 0 or ((txt[i - 1][2] and pressed) or (txt[i - 1][1] > 0.0 and timer.is_stopped())):
					var buffering = false
					for d in get_tree().get_nodes_in_group("vn_dialogue"):
						if !d.get_node("InputBuffer").is_stopped():
							buffering = true
							break
					if !buffering:
						var writing = false
						for d in get_tree().get_nodes_in_group("vn_dialogue"):
							if d.text_writing:
								d.skip_text()
								writing = true
								
						if !writing:
							if i < txt.size():
								var info = txt[i]
								var time = info[1]
								
								for action in info[0]:
									callv(vn_action_functions[action[0]], action[1])
								
								if time > 0.0:
									timer.start(time)
								dialogue_advance = true
							else:
								finished = true
				if i == txt.size() and !txt[i - 1][2] and txt[i - 1][1] == 0.0:
					finished = true
		if finished:
			dialogue_step = 0
			if complete:
				Global.set_pause_state(Global.PauseState.NORMAL)
				vn_handler.end_cutscene()
				current_event = 0
				step = 0
			else:
				auto_event_complete = true
				step_advance = true
				
	var step_on_finished = txt.size() + step_offset
	return step_on_finished

func vn_portrait_create(id, type, fadein = true, dir = 1, variants = [], replace_variants = [], pos_offset = Vector2.ZERO, starting_pos = Vector2.ZERO):
	var portrait = vn_handler.get_portrait(id)
	if portrait and portrait.dict_name != type:
		portrait.get_parent().remove_child(portrait)
		portrait.queue_free()
		portrait = null
		
	if !portrait:
		portrait = vn_handler.spawn_portrait(id, type, fadein, dir, pos_offset, starting_pos)
		if variants != []:
			portrait.set_variants(variants, replace_variants)
		
func vn_dialogue_create(portrait_id, dialogue_id, text, type = "", clear_previous = true, mouth_override = -1, speaking_time = 3.0, extra_dist = Vector2.ZERO):
	if type == "":
		type = "default"
	vn_handler.clear_all_dialogue(true, true)
	vn_handler.call_deferred("spawn_dialogue", portrait_id, dialogue_id, text, type, clear_previous, mouth_override, speaking_time, extra_dist)
	
func vn_illustration_create(frames, category, image, clear_previous = true, instant = true):
	if clear_previous and category != "":
		vn_handler.clear_illustration(category, "", instant)
	vn_handler.spawn_illustration(category, frames, image, instant)
	
func vn_portrait_newtype(id, type):
	var portrait = vn_handler.get_portrait(id)
	if portrait and portrait.dict_name != type:
		portrait.dict_name = type
		vn_portrait_refresh(portrait)
		
func vn_portrait_newvariants(id, variants, replace_variants):
	var portrait = vn_handler.get_portrait(id)
	if portrait:
		portrait.current_variants = variants
		portrait.current_replace_variants = replace_variants
		vn_portrait_refresh(portrait)
		
func vn_portrait_newpos(id, pos):
	var portrait = vn_handler.get_portrait(id)
	if portrait:
		portrait.position = pos
		vn_portrait_refresh(portrait)
		
func vn_portrait_face(id, dir, instant = false):
	var portrait = vn_handler.get_portrait(id)
	if portrait:
		portrait.set_facing(dir, instant)

func vn_portrait_slide(id, pos):
	var portrait = vn_handler.get_portrait(id)
	if portrait:
		portrait.autoset_position(pos)
	
func vn_portrait_refresh(portrait):
	if portrait:
		var saved_id = portrait.id
		var saved_type = portrait.dict_name
		var saved_offset = portrait.current_offset
		var saved_pos = portrait.position
		var saved_dir = portrait.side
		var saved_variants = portrait.current_variants
		var saved_replace_variants = portrait.current_replace_variants
		
		portrait.get_parent().remove_child(portrait)
		portrait.queue_free()
		portrait = null
		
		vn_portrait_create(saved_id, saved_type, false, saved_dir, saved_variants, saved_replace_variants, saved_offset, saved_pos)
	
func vn_portrait_clear(id, clear_side = 0):
	var portrait = vn_handler.get_portrait(id)
	if portrait:
		portrait.clear_side = clear_side
		portrait.clear()
		
func vn_dialogue_clear(id):
	vn_handler.portrait_clear_all_dialogue(id)
	
func vn_dialogue_clear_all():
	vn_handler.clear_all_dialogue()
	
func vn_illustration_clear_category(category, instant = true):
	vn_handler.clear_illustration(category, "", instant)
	
func vn_illustration_clear_all(instant = true):
	vn_handler.clear_all_illustrations(instant)

func get_npc(id):
	for e in get_tree().get_nodes_in_group("entity"):
		if e.npc_id == id:
			return e.get_node("EventHandler")
	print("NPC not found!")
	return null
