extends Node

var adventure_connections = {
	Enums.Adventures.forest: [
		[Enums.Adventures.forest_village, "Village"],
		[Enums.Adventures.none, ""],
		[Enums.Adventures.none, ""],
		[Enums.Adventures.explore, ""]
	],
	Enums.Adventures.forest_village: [
		[Enums.Adventures.forest, "Forest"],
		[Enums.Adventures.none, ""],
		[Enums.Adventures.battle, ""]
	]
}
