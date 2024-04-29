class_name ColorBackground
extends Node2D

func _ready():
	$ColorRect.size = Global.VIEW_SIZE + Vector2(Global.VIEW_SIZE.x / 2, Global.VIEW_SIZE.y / 2)

func _process(delta):
	var view = get_viewport()
	$ColorRect.position = -view.canvas_transform.origin - Vector2(Global.VIEW_SIZE.x / 4, Global.VIEW_SIZE.y / 4)
	
