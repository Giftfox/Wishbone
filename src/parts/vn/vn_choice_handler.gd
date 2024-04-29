extends Node2D

var choices := []
var boxes := []
var selection := 0
var input_buffer := false
var picked := false
var a_target := 0.0

var box_resource = preload("res://src/ui/dialogue_choice.tscn")

func _ready():
	Event.choice_handler = self

func _process(delta):
	a_target = 0
	if !choices.is_empty():
		if !input_buffer and !picked:
			var shift = Global.get_cardinal_input()
			if shift.y != 0:
				selection = Global.shift_index(selection, 0, choices.size() - 1, shift.y)
			if Input.is_action_just_pressed("menu_accept"):
				picked = true
		for i in range(boxes.size()):
			var box = boxes[i]
			box = Global.clear_object(box)
			if box:
				box.get_node("Selector").visible = selection == i
				box.get_node("Label").modulate = Color(1, 1, 1) if selection == i else Color(0.6, 0.6, 0.6)
		input_buffer = false
		a_target = 1
	
	modulate.a = Global.approach_value(modulate.a, a_target, 0.2 * delta * 60)

func create_choices(arr, starting_cursor = 0):
	finish()
	selection = starting_cursor
	picked = false
	input_buffer = true
	for i in range(arr.size()):
		var choice = arr[i]
		choices.append(choice)
		var box = box_resource.instantiate()
		add_child(box)
		boxes.append(box)
		box.position = Vector2(1280, 720 + 250 * (i - arr.size() / 2 + 0.5))
		box.get_node("Label").text = choice

func finish():
	for box in boxes:
		box = Global.clear_object(box)
		if box:
			box.queue_free()
	boxes.clear()
	choices.clear()
