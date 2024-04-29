extends Sprite2D

@export var input: String = ""
var menu

func _process(delta):
	menu = Global.clear_object(menu)
	if !menu and Global.gui:
		menu = Global.gui.get_node("Menu")
	
	if menu:
		if input != "":
			visible = true
			var events = InputMap.action_get_events(input)
			var key_events = []
			var button_events = []
			for e in events:
				if e is InputEventKey:
					key_events.append(e)
				else:
					button_events.append(e)
			
			if menu.last_action_is_button:
				$Label.visible = false
				self_modulate.a = 1.0
				events = button_events
				if menu.button_images.has(events[0].button_index):
					frame = menu.button_images[events[0].button_index][menu.gamepad_type]
				else:
					visible = false
			else:
				$Label.visible = true
				self_modulate.a = 0.0
				events = key_events
				if events.size() > 0:
					if events[0].keycode == KEY_DOWN:
						self_modulate.a = 1.0
						$Label.visible = false
						frame = 63
					else:
						if Stats.keynames.has(events[0].keycode):
							$Label.text = "[" + Stats.keynames[events[0].keycode] + "]"
						else:
							visible = false
		else:
			visible = false
	
	for c in $Label.get_children():
		c.text = $Label.text
