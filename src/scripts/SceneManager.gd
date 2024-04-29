extends Node2D

signal scene_load_started()
signal scene_loaded()

var game_view: SubViewport
var game_container: SubViewportContainer
var dir = "src/rooms/"
var ext = ".tscn"

func find_scene(path: String) -> bool:
	if ResourceLoader.exists(dir + path + ext):
		return true
	return false

func load_scene(path: String) -> void:
	if find_scene(path):
		call_deferred("_load_scene_deferred", path)
	
func _load_scene_deferred(path: String) -> void:
	if game_view:
		emit_signal("scene_load_started")
		for n in game_view.get_children():
			if !n.is_in_group("no_destroy"):
				n.free()
		var pscene = load(dir + path + ext)
		var scene = pscene.instantiate()
		game_view.add_child(scene)
		scene.get_node("RoomControl").reready()
		emit_signal("scene_loaded")
	else:
		push_error("Could not load scene - game viewport not found.")
