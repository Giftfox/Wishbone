extends SFX

func _ready():
	sounds = {
		"": null,
		"shift": preload("res://assets/sounds/sfx/menu_shift.wav"),
		"confirm": preload("res://assets/sounds/sfx/menu_confirm.wav"),
		"cancel": preload("res://assets/sounds/sfx/menu_cancel.wav"),
	}
		
func sfx_priority(id = "") -> bool:
	if id == "":
		id = current_id
		if !playing:
			return false
	match id:
		"confirm", "cancel":
			return true
	return false
