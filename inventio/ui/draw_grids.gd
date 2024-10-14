extends Node2D

@onready var p = get_parent()

func _ready():
	TrackData.grids.append(NoteGrid.new(Vector2(0, 2), Rect2(0, 3, 16, 3), p.main_scale, 1.68))
	# TrackData.grids.append(NoteGrid.new(Vector2(0, 3), Rect2(0, 5, 16, 1), p.main_scale, 0.92))
	# g = TrackData.grids[0]

func redraw():
	queue_redraw()
	pass

func _input(_action):
	pass

func _draw():
	# draw pitch gridlines
	for g in TrackData.grids:
		for i in range(floor(g.bounds.position.y), ceil(g.bounds.end.y) + 1):
			var line_color = Color.from_hsv(0, 1, 1, 1) 
			if (i >= g.bounds.position.y and i <= g.bounds.end.y) or is_equal_approx(i, g.bounds.position.y):
				draw_line( # equaves
					p.view_transform * (Vector2(0, i)), 
					p.view_transform * (Vector2(g.bounds.size.x, i)), 
					line_color, p.pen_stroke_width * 3, true
				)
			for j in range(1, len(p.main_scale) - 1): # not equaves
				var s = i + p.main_scale[j]
				if s < g.bounds.position.y and not(is_equal_approx(s, g.bounds.position.y)):
					continue # below bounds
				if s > g.bounds.end.y and not(is_equal_approx(s, g.bounds.end.y)):
					continue # above bounds
				line_color = Color.from_hsv(s*13, 1, 1, 1) 
				draw_line(
					p.view_transform * (Vector2(0, s)), 
					p.view_transform * (Vector2(g.bounds.size.x, s)), 
					line_color, p.pen_stroke_width, true
				)
		
		# draw time gridlines
		
		for i in range(0, ceil(g.bounds.size.x) + 1):
			for j in range(0, ceil(g.rhythm)):
				var x_ = (i + j/g.rhythm) * g.tempo
				if x_ > g.bounds.size.x and not(is_equal_approx(x_, g.bounds.size.x)):
					break 
				var timeLineColor
				if j == 0:
					timeLineColor = Color(0.1, 0.1, 0.1, 1)
				else:
					timeLineColor = Color(0.6, 0.6, 0.6, 1)
				draw_line(
					p.view_transform * Vector2(x_ + g.root_position.x, g.bounds.position.y), 
					p.view_transform * Vector2(x_ + g.root_position.x, g.bounds.position.y + g.bounds.size.y), 
					timeLineColor, p.pen_stroke_width, true
				)
		pass
	
	if p.is_editing_grids:
		var selected_grid = TrackData.grids[0] # TODO the grid to be selected
		# draw_rect(p.view_transform * selected_grid.bounds, Color.CORNFLOWER_BLUE, false, 5)
		var bounds = p.view_transform * selected_grid.bounds
		var px = bounds.position.x; var py = bounds.position.y;
		var ex = bounds.end.x; var ey = bounds.end.y
		var color = Color.CORNFLOWER_BLUE; var width = 5; var dash = 16
		draw_dashed_line(Vector2(px, py), Vector2(ex, py), color, width, dash)
		draw_dashed_line(Vector2(px, py), Vector2(px, ey), color, width, dash)
		draw_dashed_line(Vector2(ex, py), Vector2(ex, ey), color, width, dash)
		draw_dashed_line(Vector2(px, ey), Vector2(ex, ey), color, width, dash)
		
		# TODO make text always visible 
		draw_string(ThemeDB.fallback_font, bounds.position, selected_grid.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
