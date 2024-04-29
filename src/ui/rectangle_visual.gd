@tool

class_name RectangleVisual
extends Node2D

@export var size := Vector2(100, 100)
@export var color := Color(1.0, 1.0, 1.0)
@export var fill_color := Color(0.0, 0.0, 0.0, 0.0)
@export var thickness := 1
@export var horizontal_centered := false
@export var vertical_centered := false

func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	if horizontal_centered:
		rect.position.x -= size.x / 2
	if vertical_centered:
		rect.position.y -= size.y / 2
		
	draw_rect(rect, fill_color)
	draw_line(rect.position - Vector2(0, thickness / 2), Vector2(rect.position.x, rect.end.y) + Vector2(0,  ceil(float(thickness) / 2.0)), color, thickness)
	draw_line(rect.position - Vector2(thickness / 2, 0), Vector2(rect.end.x, rect.position.y) + Vector2( ceil(float(thickness) / 2.0), 0), color, thickness)
	draw_line(Vector2(rect.end.x, rect.position.y) - Vector2(0, thickness / 2), rect.end + Vector2(0, ceil(float(thickness) / 2.0)), color, thickness)
	draw_line(Vector2(rect.position.x, rect.end.y) - Vector2(thickness / 2, 0), rect.end + Vector2(ceil(float(thickness) / 2.0), 0), color, thickness)
	
func _process(delta):
	queue_redraw()
