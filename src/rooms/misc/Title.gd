extends Node2D

enum Options {
	start,
	cont,
	settings,
	exit
}
var option_names = {
	Options.start: "Start",
	Options.cont: "Continue",
	Options.settings: "Settings",
	Options.exit: "Quit"
}

var cursor := 0
var available_options = []
var leaving := false

#func _ready():
#	available_options = [Options.start, Options.exit]

func _process(delta):
	if !leaving:
		Global.current_room_control.room_change_from_data()
		leaving = true
		
#	if Global.current_pausestate == Global.PauseState.NORMAL:
#		var shift = Global.shift_input("menu_left", "menu_right")
#		#cursor = Global.shift_index(cursor, 0, available_options.size() - 1, shift)
#		cursor += shift
#		cursor = clamp(cursor, 0, available_options.size() - 1)
#		
#		if Input.is_action_just_pressed("menu_accept"):
#			match available_options[cursor]:
#				Options.start:
#					Global.current_room_control.room_change("misc/hub")
#				Options.exit:
#					Global.current_room_control.game_end()
#					
#	$Option.text = option_names[available_options[cursor]]
#	$ArrowLeft.visible = cursor > 0
#	$ArrowRight.visible = cursor < available_options.size() - 1
