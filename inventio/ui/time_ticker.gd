extends Node2D

@onready var v = $"../../../SubViewportContainer/SubViewport (everything else)/visualizer"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	for i in range(0, ceil(TrackData.track_dimensions.x) + 1):
		var mark = (v.view_transform * Vector2(i, 0)).x
		draw_line(Vector2(mark, 0), Vector2(mark, 20), Color(Color.DODGER_BLUE, 1.0), 3)
		draw_string(ThemeDB.fallback_font, Vector2(mark + 3, 19), String.num(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Color.DODGER_BLUE, 1.0))
	for g in TrackData.grids:
		for i in range(0, g.bounds.size.x + 1):
			var mark = (v.view_transform * Vector2(i * g.tempo + g.bounds.position.x, 0)).x
			draw_line(Vector2(mark, 20), Vector2(mark, 40), Color(Color.RED, 1.0), 3)
			draw_string(ThemeDB.fallback_font, Vector2(mark + 3, 39), String.num(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(Color.RED, 1.0))
