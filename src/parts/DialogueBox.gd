class_name DialogueBox
extends ModularBox

signal dialogue_finished()

var target_text := ""
var pointer := -1
var stopped := false
var keep_on := false

func _ready():
	SceneManager.connect("scene_load_started",Callable(self,"_on_Scene_Load_Started"))

func _process(delta):
	super._process(delta)
	if Input.is_action_just_pressed("menu_accept"):
		$Label.text = target_text
		pointer = target_text.length()
	elif pointer >= 0 and pointer < target_text.length():
		if !stopped:
			for i in range(round(delta * 60)):
				if pointer < target_text.length():
					$Label.text += target_text[pointer]
					pointer += 1
			#$SFX.play()
	elif pointer >= 0:
		stopped = true
		emit_signal("dialogue_finished")
	$LabelShadow.text = $Label.text
	
	visible = target_text != "" or keep_on
	$Icon.visible = stopped

func start_message(msg: String, keep = false) -> void:
	target_text = msg
	$Label.text = ""
	$LabelShadow.text = ""
	pointer = 0
	stopped = false
	keep_on = keep
	Event.dialogue_advance = false
	
	visible = true
	
func continue_message(msg: String) -> void:
	target_text += msg
	stopped = false
	Event.dialogue_advance = false

func end_message() -> void:
	pointer = -1
	target_text = ""
	if !keep_on:
		visible = false
	Event.dialogue_advance = false
		
func _on_Scene_Load_Started():
	keep_on = false
	end_message()

func _on_clickzone_left_clicked():
	if !stopped:
		$Label.text = target_text
		pointer = target_text.length()
	else:
		Event.dialogue_advance = true
