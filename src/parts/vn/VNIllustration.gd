class_name VNIllustration
extends AnimatedSprite2D

var a_target := 0.0
var destroy := false
var destroy_others := false
var instant_appear := false
var category := ""
var frames := ""
var id := ""

var frame_info = {
	"nuez": preload("res://src/parts/vn/illustrations/nuez_frames.tres"),
	"alqo_visit": preload("res://src/parts/vn/illustrations/alqo_visit_frames.tres")
}

func _ready():
	modulate.a = 0.0

func _process(delta):
	modulate.a = Global.approach_value(modulate.a, a_target, 0.1)
	if destroy and modulate.a <= 0.0:
		queue_free()
	if destroy_others and modulate.a >= 1.0:
		destroy_others = false
		for n in get_tree().get_nodes_in_group("vn_illustration"):
			if n != self:
				n.queue_free()

func appear(image):
	if frame_info.keys().has(frames):
		sprite_frames = frame_info[frames]
	play(image)
	a_target = 1.0
	if instant_appear:
		modulate.a = 1.0

func clear():
	a_target = 0.0
	destroy = true
