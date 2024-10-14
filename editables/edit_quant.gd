extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text_changed.connect(_on_text_changed)

func _on_text_changed(new_text):
	if int(new_text) is int or float(new_text) is float:
		pass # TrackData.beats_per_bar = float(new_text) TODO put new stuff here
