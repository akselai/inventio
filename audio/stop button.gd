extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

signal halt_play_button

func _pressed():
	TrackData.start_play_time = 0.0
	TrackData.current_play_time = -INF
	TrackData.is_playing = false
	halt_play_button.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
