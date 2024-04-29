class_name Weather
extends Node2D

enum types {
	rain,
	sun,
	snow,
	nightbugs
}

var type_nodes = {
	types.rain: "Rain",
	types.sun: "Sun",
	types.snow: "Snow",
	types.nightbugs: "Nightbugs" 
}

var current_types := []

func change_weather(_types):
	for node in type_nodes.keys():
		get_node(node).visible = _types.has(node)
		for c in get_node(node).get_children():
			if c is CPUParticles2D:
				c.emitting = _types.has(node)
	current_types.clear()
	for type in _types:
		if !current_types.has(type):
			current_types.append(type)

func add_weather(_types):
	for type in current_types:
		_types.append(type)
	change_weather(_types)
	
func remove_weather(_types):
	for type in _types:
		current_types.erase(type)
	change_weather(current_types)
