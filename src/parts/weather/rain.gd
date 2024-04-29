extends Node2D

@onready var offset = position

func _process(delta):
	position = -get_viewport().canvas_transform.origin + offset
