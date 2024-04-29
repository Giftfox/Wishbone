extends MenuDropdown

func _ready():
	pass
	
func _process(delta):
	if active:
		if controller:
			var content_size = controller.content_size
			$ContentRect.size = Vector2(content_size.x, content_size.y)
			var margin = Vector2(25, 25)
			var acting_size = content_size - Vector2(margin.x * 2, margin.y * 2)
			var item_size = Vector2(290, 250)
			var item_margin = Vector2(45, 25)
			var columns = int(floor(acting_size.x / item_size.x))
			var rows = int(floor(acting_size.y / item_size.y))
			selection_matrix.clear()
			for y in range(rows):
				selection_matrix.append([])
				for x in range(columns):
					selection_matrix[y].append(-1)
			
			for i in range(Stats.items.size()):
				var pos = Vector2(i % columns, int(floor(i / columns)))
				selection_matrix[pos.y][pos.x] = Stats.items[i]
				
			shift_cursor([])
			
			$ContentRect/Selector.size = item_size - item_margin * 2
			$ContentRect/Selector.position = Vector2(cursor.x * item_size.x + margin.x + item_margin.x, cursor.y * item_size.y + margin.y + item_margin.y)
