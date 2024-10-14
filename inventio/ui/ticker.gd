extends Node2D

var view_transform

func _ready():
	view_transform = get_parent().view_transform

func _process(_delta):
	view_transform = get_parent().view_transform
	queue_redraw()

func _draw():
	if TrackData.is_playing:
		draw_line(
			view_transform * Vector2(TrackData.current_play_time, 0), 
			view_transform * Vector2(TrackData.current_play_time, TrackData.track_dimensions.y),
			Color(Color.RED, 0.3), 8
		)
