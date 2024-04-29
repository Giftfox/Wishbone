extends Menu

func _ready():
	box_resource = preload("res://src/parts/TitleBox.tscn")

func _process(delta):
	if !input_buffer:
		if active and can_switch():
			Global.gui.get_node("HUD/TopRow").position.y = -120
			position = Vector2.ZERO
			
			if Input.is_action_pressed("menu_accept"):
				if grid_pos.y == 3:
					if $Timer.is_stopped():
						$Timer.start()
		if !Input.is_action_pressed("menu_accept"):
			$Timer.stop()

func can_switch():
	if Global.current_pausestate == Global.PauseState.TRANSITION or !$Timer.is_stopped() or $AnimationPlayer.is_playing() or $Credits.visible:
		return false
	return true

func draw_boxes():
	super.draw_boxes()
	$SelectionBox.position = Vector2(432, 40 + grid_pos.y * 88)

func draw_box(pos = Vector2.ZERO):
	var box = super.draw_box(pos)
	if box:
		box.position = Vector2(432, 40 + 88 * pos.y)
		if pos.y == 0:
			box.get_node("ShadedLabel").text = "Start"
		if pos.y == 1:
			box.get_node("ShadedLabel").text = "Exit"
		if pos.y == 2:
			box.get_node("ShadedLabel").text = "Credits"
		if pos.y == 3:
			box.get_node("ShadedLabel").text = "Delete Data"
			if !$Timer.is_stopped():
				box.get_node("ShadedLabel").text += " (" + str(ceil($Timer.time_left)) + ")"

func menu_input(type: String):
	if !$Credits.visible:
		if type == "confirm":
			if grid_pos.y == 0:
				$AnimationPlayer.play("disappear")
				return "confirm"
			if grid_pos.y == 1:
				Event.run_event(81)
				return "cancel"
			if grid_pos.y == 2:
				$Credits.visible = true
				return "confirm"
	else:
		$Credits.visible = false
		return "cancel"
	return ""


func _on_Timer_timeout():
	if Input.is_action_pressed("menu_accept") and grid_pos.y == 3:
		Stats.initialize_data()
		Event.run_event(80)

func _on_AnimationPlayer_animation_finished(anim_name):
	Global.set_pause_state(Global.PauseState.NORMAL)
	active = false
	Global.current_room_control.play_music("Music")
	#if Global.current_room_control.scene_path == "misc/Indoors" and !Stats.get_flag(Stats.Flags.awoken):
	#	Event.run_event(63)

func _on_GUI_fade_finished(out):
	if !out and active:
		Global.set_pause_state(Global.PauseState.EVENT)
