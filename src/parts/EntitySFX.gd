class_name EntitySFX
extends SFX

var sabotage := false

func _ready():
	sounds = {
		"": null
	}

func _process(delta):
	if sabotage and !playing:
		queue_free()

func play_sfx(id = "") -> void:
	if sounds.has(id):
		var sfx = sounds[id]
		if sfx and (!sfx_priority() or sfx_priority(id)):
			if playing:
				stop()
			stream = sfx
			play()
		
func sfx_priority(id = "") -> bool:
	if id == "":
		id = current_id
		if !playing:
			return false
	match id:
		"death":
			return true
	return false
