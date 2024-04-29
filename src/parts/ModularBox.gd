class_name ModularBox
extends Node2D

@export var size: Vector2 = Vector2(220, 100)
@onready var part_size = Vector2($EdgeL.region_rect.end.x, $EdgeU.region_rect.end.y)

func _process(delta):
	var realsize = size - part_size * 2
	
	$CornerUL.position = Vector2(0, 0)
	$CornerUR.position = Vector2(part_size.x + realsize.x, 0)
	$CornerDL.position = Vector2(0, part_size.y + realsize.y)
	$CornerDR.position = Vector2(part_size.x + realsize.x, part_size.y + realsize.y)
	
	$EdgeU.position = Vector2(part_size.x, 0)
	$EdgeU.region_rect.end = Vector2(realsize.x, part_size.y)
	$EdgeD.position = Vector2(part_size.x, part_size.y + realsize.y)
	$EdgeD.region_rect.end = Vector2(realsize.x, part_size.y)
	$EdgeL.position = Vector2(0, part_size.y)
	$EdgeL.region_rect.end = Vector2(part_size.x, realsize.y)
	$EdgeR.position = Vector2(part_size.x + realsize.x, part_size.y)
	$EdgeR.region_rect.end = Vector2(part_size.x, realsize.y)
	
	$Middle.position = part_size
	$Middle.region_rect.end = realsize
	
	#$NameLabel.position = Vector2(8, 0)
	#$NameLabel.text = text[0]
	#$NameLabel.get_node("Label").size = realsize - Vector2(8, 0)
	#$DescriptionLabel.position = Vector2(8, 26)
	#$DescriptionLabel.text = text[1]
	#$DescriptionLabel.get_node("Label").size = realsize - Vector2(8, 0)
		
	#modulate.a = Global.approach_value(modulate.a, a_target, 0.1)
