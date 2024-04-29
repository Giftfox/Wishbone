class_name MenuDropdown
extends Node2D

var active := false
var can_switch := true
var cursor := Vector2.ZERO
var selection_matrix := []
var input_buffer := false
var controller

func activate(on = true):
	active = on
	visible = on
	if !on:
		cursor = Vector2.ZERO
	else:
		input_buffer = true

func shift_cursor(invalid_vals = [-1]):
	var shift = Global.get_cardinal_input()
	var cursor_start = cursor
	
	cursor.x = Global.shift_index(cursor.x, 0, selection_matrix[cursor.y].size() - 1, shift.x)
	while invalid_vals.has(selection_matrix[cursor.y][cursor.x]) and cursor.x != cursor_start.x:
		cursor.x = Global.shift_index(cursor.x, 0, selection_matrix[cursor.y].size() - 1, shift.x)
	
	cursor.y = Global.shift_index(cursor.y, 0, selection_matrix.size() - 1, shift.y)
	while invalid_vals.has(selection_matrix[cursor.y][cursor.x]) and cursor.y != cursor_start.y:
		cursor.y = Global.shift_index(cursor.y, 0, selection_matrix.size() - 1, shift.y)
