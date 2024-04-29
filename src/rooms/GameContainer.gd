extends SubViewportContainer

#onready var base_view_size = Global.VIEW_SIZE
@export var view_size_inc_x: int = 0
@export var view_size_inc_y: int = 0
var view_size_inc: Vector2

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	SceneManager.game_container = self

#func _process(delta):
#	view_size_inc = Vector2(view_size_inc_x, view_size_inc_y)
#	if Global.VIEW_SIZE != base_view_size + view_size_inc:
#		Global.VIEW_SIZE = base_view_size + view_size_inc
#		$GameView.size = Global.VIEW_SIZE
#		size = Global.VIEW_SIZE
#		OS.set_window_size(Global.VIEW_SIZE * Stats.game_settings[Stats.Settings.screen_size])
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Global.VIEW_SIZE, 1)
#		OS.set_window_position((OS.get_screen_size(OS.get_current_screen()) / 2) - (OS.get_window_size() / 2))
