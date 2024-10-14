class_name Note extends Resource

var note_on = 0.0
var duration = 1.0
var pitch = 1.0
var selected = false

func _init(on, dur, pitch_, selected_):
	note_on = on; duration = dur; 
	pitch = pitch_; selected = selected_

func copy():
	return Note.new(note_on, duration, pitch, selected)
