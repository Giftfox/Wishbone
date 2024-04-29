extends MenuDropdown

var label_resource = preload("res://src/ui/settings_label.tscn")
var header_resource = preload("res://src/ui/settings_header.tscn")

enum Tabs {
	graphics,
	gameplay,
	sound
}
var tab_info = {
	Tabs.graphics: ["Graphics", [Stats.Settings.screen_size]],
	Tabs.gameplay: ["Gameplay", [Stats.Settings.fps_cap]],
	Tabs.sound: ["Sound", [Stats.Settings.master_vol, Stats.Settings.music_vol, Stats.Settings.sfx_vol]]
}

enum setting_type {manual, sequential, keybind, special}
var settings_info = {
	Stats.Settings.screen_size: ["Window   Type", [[1, "Windowed"], [2, "Fullscreen"]], setting_type.manual],
	Stats.Settings.fps_cap: ["FPS   Cap", [[1, "30"], [0, "60"]], setting_type.manual],
	Stats.Settings.master_vol: ["Master   Volume", [0, 10], setting_type.sequential],
	Stats.Settings.music_vol: ["Music   Volume", [0, 10], setting_type.sequential],
	Stats.Settings.sfx_vol: ["SFX   Volume", [0, 10], setting_type.sequential]
}

var current_tab := Tabs.graphics
var current_tab_saved := Tabs.graphics
var labels := []
var headers := []

var currently_setting := false
var saved_setting_value := -1

func _ready():
	build_headers()
	rebuild_labels()
	set_visuals()

func _process(delta):
	if active:
		if !input_buffer:
			if currently_setting:
				can_switch = false
				
				var index = floor(cursor.y / 2) + cursor.x
				var setting = tab_info[current_tab][1][index]
				var setting_info = settings_info[setting]
				var current_setting_index = get_setting_index(setting)
				var new_setting_index = 0
				var new_setting_value = Stats.game_settings[setting]
				
				var shift = Global.get_cardinal_input()
				if shift.x != 0:
					if current_setting_index != -1:
						if setting_info[2] == setting_type.manual:
							new_setting_index = Global.shift_index(current_setting_index, 0, setting_info[1].size() - 1, shift.x)
							new_setting_value = setting_info[1][new_setting_index][0]
						if setting_info[2] == setting_type.sequential:
							new_setting_index = Global.shift_index(current_setting_index, setting_info[1][0], setting_info[1][1], shift.x)
							new_setting_value = new_setting_index
					
					Stats.set_setting(setting, new_setting_value)
				else:
					if Input.is_action_just_pressed("menu_accept"):
						currently_setting = false
						saved_setting_value = -1
						DataManager.settings_save()
					elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("menu_toggle"):
						Stats.set_setting(setting, saved_setting_value)
						currently_setting = false
						saved_setting_value = -1
				
			else:
				can_switch = true
				
				shift_cursor()
				var index = selection_matrix[cursor.y][cursor.x]
				
				var tab_shift = Global.get_cardinal_input("menu_shift_left", "menu_shift_right", "", "")
				if tab_shift.x != 0:
					current_tab = Global.shift_index(current_tab, 0, Tabs.keys().size() - 1, tab_shift.x)
					cursor = Vector2.ZERO
				
				elif Input.is_action_just_pressed("menu_accept"):
					currently_setting = true
					saved_setting_value = Stats.game_settings[tab_info[current_tab][1][index]]
		
		if current_tab != current_tab_saved:
			current_tab_saved = current_tab
			set_visuals(true)
		
		set_visuals()
	
	input_buffer = false
		
func get_setting_index(setting):
	var type = settings_info[setting][2]
	var options = settings_info[setting][1]
	var option_index = -1
	if type == setting_type.manual:
		for i in range(options.size()):
			if Stats.game_settings[setting] == options[i][0]:
				option_index = i
				break
	if type == setting_type.sequential:
		option_index = Stats.game_settings[setting]
	return option_index

func set_visuals(rebuild_nodes = false):
	if controller:
		var content_size = controller.content_size
		$ContentRect.size = Vector2(content_size.x, content_size.y - 80)
		$ContentRect.position.y = 80
		
		selection_matrix.clear()
		
		if rebuild_nodes:
			build_headers()
			rebuild_labels()
		
		var header_count = headers.size()
		var header_width = content_size.x / header_count
		for i in range(header_count):
			var h = headers[i]
			
			h[0].position = Vector2(header_width * i, -90)
			h[0].size.x = header_width
			h[0].get_node("Rectangle").size.x = header_width
			h[0].text = tab_info[h[1]][0]
			
			var rectangle = h[0].get_node("Rectangle")
			var rectangle2 = h[0].get_node("Rectangle2")
			if current_tab == h[1]:
				rectangle.size.y = 79
				h[0].position.y = -90
				h[0].self_modulate = Color(1.0, 1.0, 1.0)
			else:
				rectangle.size.y = 69
				h[0].position.y = -80
				h[0].self_modulate = Color(0.6, 0.6, 0.6)
			rectangle2.size = rectangle.size
		
		const label_width = 650.0
		var column_count = int(floor(content_size.x / label_width))
		for i in range(labels.size()):
			var l = labels[i]
			var slabel = l.get_node("Setting")
			var pos = Vector2(i % column_count, floor(i / column_count))
			var tab = tab_info[current_tab]
			
			while pos.y >= selection_matrix.size():
				selection_matrix.append([])
			while pos.x >= selection_matrix[pos.y].size():
				selection_matrix[pos.y].append(-1)
			selection_matrix[pos.y][pos.x] = i
			
			l.position = Vector2(content_size.x / 2 + content_size.x / column_count * (pos.x - column_count / 2 + 0.5) - label_width, 30 + 90 * pos.y)
			l.text = settings_info[tab[1][i]][0]
			
			l.get_node("Rectangle").visible = cursor == pos
			if currently_setting and cursor == pos:
				slabel.modulate = Color(1.0, 1.0, 1.0)
			else:
				slabel.modulate = Color(0.6, 0.6, 0.6)
			
			var setting = tab[1][i]
			var val = Stats.game_settings[setting]
			var txt = "< DEBUG >"
			var setting_string = ""
			var first = false
			var last = false
			
			if settings_info[setting][2] == setting_type.manual:
				for j in range(settings_info[setting][1].size()):
					var v = settings_info[setting][1][j]
					if v[0] == val:
						setting_string = v[1]
						if j == 0: first = true
						if j == settings_info[setting][1].size() - 1: last = true
						break
			if settings_info[setting][2] == setting_type.sequential:
				setting_string = str(val)
				if val == settings_info[setting][1][0]: first = true
				if val == settings_info[setting][1][-1]: last = true
			
			if setting_string != "":
				if !first: txt = "< "
				else: txt = "  "
				txt += setting_string
				if !last: txt += " >"
				else: txt += "  "
			slabel.text = txt

func rebuild_labels():
	for l in labels:
		l.queue_free()
	labels.clear()
	
	var tab = tab_info[current_tab]
	var count = tab[1].size()
	for i in range(count):
		var label = label_resource.instantiate()
		$ContentRect.add_child(label)
		labels.append(label)

func build_headers():
	for h in headers:
		h[0].queue_free()
	headers.clear()
	
	var count = tab_info.keys().size()
	for i in range(count):
		var tab = tab_info[tab_info.keys()[i]]
		var header = header_resource.instantiate()
		$ContentRect.add_child(header)
		headers.append([header, tab_info.keys()[i]])
