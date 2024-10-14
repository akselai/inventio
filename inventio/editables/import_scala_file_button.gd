extends Button
@onready var import_scala_file = $"import scala file"

# Called when the node enters the scene tree for the first time.
func _ready():
	# print(literal_to_interval(" 3/2 oct"))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _pressed():
	import_scala_file.show()

func literal_to_interval(s):
	s = s.lstrip(" ")
	var value = NAN
	s = s.split(" ")[0]
	if "." in s:
		value = s.to_float() if s.is_valid_float() else NAN
		value = pow(2.0, value/1200.0)
	elif "/" in s:
		var num = s.split("/")[0]
		var den = s.split("/")[1]
		if not num.is_valid_int(): return NAN
		if not den.is_valid_int(): return NAN
		value = num.to_int() / float(den.to_int())
	return value

func parse_scala_file(file):
	file = file.split("\n")
	var pitches = []
	var head_counter = -2
	for s in file:
		if s != "" and s[0] != "!":
			if head_counter >= 0:
				pitches.append(literal_to_interval(s))
			head_counter += 1
	return pitches

signal scale_changed

func _on_import_scala_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ).get_as_text()
	TrackData.scale = parse_scala_file(file)
	scale_changed.emit()
