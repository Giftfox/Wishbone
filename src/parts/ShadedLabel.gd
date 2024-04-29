class_name ShadedLabel
extends Node2D

@export var text: String = "" : set = set_text
@export var align_left: bool = false
@export var align_top: bool = false
@export var autowrap: TextServer.AutowrapMode

func _ready():
	if align_left:
		$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if align_top:
		$Label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		
	$Sprite2D.visible = false
	
	$Label/zfix/LabelShadowL.horizontal_alignment = $Label.horizontal_alignment
	$Label/zfix/LabelShadowR.horizontal_alignment = $Label.horizontal_alignment
	$Label/zfix/LabelShadowU.horizontal_alignment = $Label.horizontal_alignment
	$Label/zfix/LabelShadowD.horizontal_alignment = $Label.horizontal_alignment
	$Label/zfix/LabelShadowL.vertical_alignment = $Label.vertical_alignment
	$Label/zfix/LabelShadowR.vertical_alignment = $Label.vertical_alignment
	$Label/zfix/LabelShadowU.vertical_alignment = $Label.vertical_alignment
	$Label/zfix/LabelShadowD.vertical_alignment = $Label.vertical_alignment
	
	$Label.autowrap_mode = autowrap
	$Label/zfix/LabelShadowL.autowrap_mode = autowrap
	$Label/zfix/LabelShadowR.autowrap_mode = autowrap
	$Label/zfix/LabelShadowU.autowrap_mode = autowrap
	$Label/zfix/LabelShadowD.autowrap_mode = autowrap
	
	$Label/zfix/LabelShadowL.add_theme_font_override("font", $Label.get_theme_font("font"))
	$Label/zfix/LabelShadowR.add_theme_font_override("font", $Label.get_theme_font("font"))
	$Label/zfix/LabelShadowU.add_theme_font_override("font", $Label.get_theme_font("font"))
	$Label/zfix/LabelShadowD.add_theme_font_override("font", $Label.get_theme_font("font"))

func _process(delta):
	set_text(text)
	
func set_text(t):
	text = t
	$Label.text = text
	$Label/zfix/LabelShadowL.text = text
	$Label/zfix/LabelShadowR.text = text
	$Label/zfix/LabelShadowU.text = text
	$Label/zfix/LabelShadowD.text = text

	$Label/zfix/LabelShadowL.size = $Label.size
	$Label/zfix/LabelShadowR.size = $Label.size
	$Label/zfix/LabelShadowU.size = $Label.size
	$Label/zfix/LabelShadowD.size = $Label.size
	
