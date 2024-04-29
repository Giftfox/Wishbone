extends Node

var default_dir := "user://"

func settings_save() -> void:
	var path = "settings.kitty"
	var file
	
	file = file_open(path)
	file.store_buffer(Stats.game_settings)
	
	file = null

func settings_load() -> void:
	var path = "settings.kitty"
	var file
	
	if FileAccess.file_exists(default_dir + path):
		file = file_open(path)
		Stats.game_settings = file.get_buffer(file.get_length())
		file = null
	else:
		Stats.initialize_settings()
		settings_save()
		
	Stats.set_all_settings()

func window_save() -> void:
	var path = "window.kitty"
	var file
	
	var data = []
	var xpos = num_to_hex(int(DisplayServer.window_get_position().x), 6)
	data.append(base_convert(xpos.substr(0, 2), 16, 10).to_int())
	data.append(base_convert(xpos.substr(2, 2), 16, 10).to_int())
	data.append(base_convert(xpos.substr(4, 2), 16, 10).to_int())
	var ypos = num_to_hex(int(DisplayServer.window_get_position().y), 6)
	data.append(base_convert(ypos.substr(0, 2), 16, 10).to_int())
	data.append(base_convert(ypos.substr(2, 2), 16, 10).to_int())
	data.append(base_convert(ypos.substr(4, 2), 16, 10).to_int())
	
	file = file_open(path)
	file.store_buffer(data)
	
	file = null

func window_load() -> void:
	var path = "window.kitty"
	var file
	
	if FileAccess.file_exists(default_dir + path):
		file = file_open(path)
		var data = file.get_buffer(file.get_length())
		file = null
		var pos = Vector2.ZERO
		pos.x = combine_bytes([data[0], \
								data[1], \
								data[2]])
		pos.y = combine_bytes([data[3], \
								data[4], \
								data[5]])
		DisplayServer.window_set_position(pos)
	else:
		#DisplayServer.window_set_position(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()) * 0.5 - DisplayServer.window_get_size() * 0.5)
		window_save()

func data_save(index := 0) -> void:
	var path = "profile" + str(index) + ".kitty"
	var file
	
	#data_separate(Stats.game_data[Stats.Data.highest_full_days], Stats.Data.highest_full_days, 2)
	
	file = file_open(path)
	file.store_buffer(Stats.game_data)
	
	file = null
	
	if Global.current_room_control and Global.current_room_control.has_player:
		var n = Global.gui.get_node("HUD/SaveIcon/AnimationPlayer")
		if n.current_animation == "":
			n.play("appear")

func data_load(index := 0) -> void:
	var path = "profile" + str(index) + ".kitty"
	var file
	
	Stats.initialize_data_array()
	
	if FileAccess.file_exists(default_dir + path):
		file = file_open(path)
		Stats.game_data = file.get_buffer(file.get_length())
		file = null
		
		if Stats.game_data[Stats.Data.version] == Stats.data_version:
			pass
			#Stats.game_data[Stats.Data.highest_full_days] = data_combine(Stats.Data.highest_full_days, 2)
			
			#Stats.reset_global_vars()
		else:
			Stats.initialize_data()
			data_save(index)
	else:
		Stats.initialize_data()
		data_save(index)
	
func data_separate(val, start_index, _len):
	var combined = num_to_hex(val, _len * 2)
	for i in range(_len):
		Stats.game_data[start_index + i] = base_convert(combined.substr(i * 2, 2), 16, 10).to_int()
		
func data_combine(start_index, _len):
	var arr = []
	for i in range(_len):
		arr.append(Stats.game_data[start_index + i])
	return combine_bytes(arr)
	
func file_delete(path: String) -> void:
	var dir = DirAccess.open(default_dir)
	dir.remove(path)

func file_create(path: String):
	var file = FileAccess.open(default_dir + path, FileAccess.WRITE)
	file = null
	
func file_open(path: String):
	if !FileAccess.file_exists(default_dir + path):
		file_create(path)
		
	return FileAccess.open(default_dir + path, FileAccess.READ_WRITE)
	
func num_to_hex(number, buffer):
	number = dec_to_hex(number)
	while number.length() < buffer:
		number = "0" + number

	return number

func dec_to_hex(dec):
	var hex
	var h
	var byte
	var hi
	var lo
	if dec:
		hex = ""
	else:
		hex = "00"
	h = "0123456789ABCDEF"
	while (dec):
		byte = dec & 255;
		hi = h[byte / 16]
		lo = h[byte % 16]
		hex = hi + lo + hex
		dec = dec >> 8
	return hex
	
func hex_to_dec(hex):
	var dec
	var h = "0123456789ABCDEF"
	var p = 0
	hex = hex.to_upper()
	dec = 0
	while p < hex.length():
		dec = dec << 4 | h.find(hex[p])
		p += 1
	return dec
	
func base_convert(number, oldbase, newbase):
	var out = ""
	number = number.to_upper()

	var leng = number.length()
	var tab = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	var i = 0
	var num = []
	while i < leng:
		num.append(tab.find(number[i]))
		i += 1

	while leng != 0:
		var divide = 0
		var newlen = 0
		i = 0
		while i < leng:
			divide = divide * oldbase + num[i];
			if (divide >= newbase):
				num[newlen] = divide / newbase
				newlen += 1
				divide = divide % newbase
			elif (newlen  > 0):
				num[newlen] = 0
				newlen += 1
			i += 1
		leng = newlen
		out = tab[divide] + out
	if out == "":
		out = "0"

	return out
	
func combine_bytes(bytes: Array):
	var number = ""
	var i = 0

	while i < bytes.size():
		var num = ""
		num = str(bytes[i])
		num = base_convert(num, 10, 16)
		number += num
		i += 1

	number = hex_to_dec(number)
	return number
