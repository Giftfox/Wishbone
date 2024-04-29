extends Node2D

var cursor := Vector2.ZERO
var active := false

var menus := [["Menus/Settings", "Settings"], ["Menus/Items", "Items"]]
var available_menus := [0, 1]
var available_menus_saved := []
var current_menu := -1

var labels := []

var queued_sound := ""
var keybind_buffer := false
var input_buffer := false

var label_resource = preload("res://src/ui/dropdown_label.tscn")

@export var open_input := ""

@onready var acting_size := Global.VIEW_SIZE * Global.WINDOW_SCALE
var content_size := Vector2.ZERO

func _ready():
	for menu in menus:
		get_node(menu[0]).controller = self
		
	set_visuals(true)

func _process(delta):
	var shift = Global.get_cardinal_input()
	
	if Global.current_room_control and Global.current_room_control.has_menu:
		if !keybind_buffer:
			if Global.current_pausestate == Global.PauseState.NORMAL and !active and !input_buffer:
				if Input.is_action_just_pressed(open_input):
					active = true
					input_buffer = true
					Global.set_pause_state(Global.PauseState.PAUSED)
					#$Anims.play("appear")
			if Global.current_pausestate == Global.PauseState.PAUSED and active and !input_buffer:
				if Input.is_action_just_pressed(open_input):
					var fail = false
					for m in menus:
						if get_node(m[0]).active and !get_node(m[0]).can_switch:
							fail = true
							break
					if !fail:
						input_buffer = true
						if current_menu != -1:
							switch_menu(-1)
						close_menu()
				else:
					if current_menu == -1:
						cursor.y = Global.shift_index(cursor.y, 0, available_menus.size() - 1, shift.y)
						
						if Input.is_action_just_pressed("menu_accept"):
							switch_menu(cursor.y)
						if Input.is_action_just_pressed("menu_cancel"):
							close_menu()
								
					else:
						var menu = get_node(menus[available_menus[current_menu]][0])
						if Input.is_action_just_pressed("menu_cancel") and menu.can_switch:
							switch_menu(-1)
							
		visible = active
		keybind_buffer = false
		input_buffer = false
		
	else:
		close_menu(false)
		visible = false
			
	if queued_sound != "":
		#$SFX.play_sfx("menu_" + queued_sound)
		queued_sound = ""
		
	if available_menus != available_menus_saved:
		available_menus_saved = available_menus.duplicate()
		set_visuals(true)
	else:
		set_visuals(false)
	

func switch_menu(new):
	get_node(menus[available_menus[current_menu]][0]).activate(false)
	current_menu = new
	if new != -1:
		get_node(menus[available_menus[current_menu]][0]).activate()

func set_visuals(rebuild_nodes = false):
	acting_size = Global.VIEW_SIZE * Global.WINDOW_SCALE
	var margin = Vector2(25, 25)
	var tab_selection_height = 100
	$TabRect.size = Vector2(acting_size.x / 5 - 100 - margin.x * 2, acting_size.y - margin.y * 2)
	$TabRect.position = margin
	$TabRect/Selector.size = Vector2($TabRect.size.x - 12, 100)
	$TabRect/Selector.position = Vector2(6, 6 + tab_selection_height * cursor.y)
	
	content_size = Vector2(acting_size.x - ($TabRect.position.x + $TabRect.size.x + margin.x * 2), acting_size.y - margin.y * 2)
	$Menus.position = Vector2($TabRect.position.x + $TabRect.size.x + margin.x, $TabRect.position.y)
	
	if rebuild_nodes:
		for l in labels:
			l.queue_free()
		labels.clear()
		
		var count = available_menus.size()
		var acting_width = Global.VIEW_SIZE.x * Global.WINDOW_SCALE
		var box_size = acting_width / count
		for i in range(count):
			var label = label_resource.instantiate()
			$TabRect.add_child(label)
			label.position = Vector2(11, 3 + tab_selection_height * i)
			label.size = Vector2($TabRect/Selector.size.x - 2, tab_selection_height - 10)
			label.text = menus[available_menus[i]][1]
			labels.append(label)

func rebuild_labels():
	for l in labels:
		l.queue_free()
	labels.clear()
	
	var count = available_menus.size()
	var acting_width = Global.VIEW_SIZE.x * Global.WINDOW_SCALE
	var box_size = acting_width / count
	for i in range(count):
		var label = label_resource.instantiate()
		add_child(label)
		label.position = Vector2((i - count / 2 + 0.5) * acting_width / count + acting_width / 2 - label.size.x / 2, 50)
		label.get_node("Rectangle").size.x = box_size - 40
		label.text = menus[available_menus[i]][1]
		labels.append(label)

func close_menu(set_state = true):
	if set_state:
		Global.set_pause_state(Global.PauseState.NORMAL)
	active = false
	current_menu = -1
	cursor = Vector2.ZERO
	for m in menus:
		get_node(m[0]).activate(false)
