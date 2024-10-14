class_name NoteGrid extends Resource

var root_position:Vector2 # starting ("root") position of the grid 
var bounds:Rect2 # length and width of the grid 
var tempo:float = 0.64 # the length of one beat in seconds
var scale # TODO (modifying this is not important for now) :Array[Interval]
var log_scale # :Array[float]
var rhythm:float = 4 # in general, replace this with a list of numbers (or a list of list of numbers, and so on)

var name:String = "Grid 1"

func _init(root_position_:Vector2, bounds_:Rect2, scale_, tempo_:float = 1.0):
	root_position = root_position_
	bounds = bounds_
	scale = scale_
	tempo = tempo_
	
	log_scale = scale.duplicate()
	log_scale.push_front(1)
	log_scale = log_scale.map(func(x): return log(x)/log(2))

func distance_to_note(note: Note):
	var left = Vector2(note.on, note.pitch)
	var right = Vector2(note.on + note.duration, note.pitch)
	var left_diff = Vector2(
		max(self.bounds.position.x - left.x, 0, left.x - self.bounds.end.x),
		max(self.bounds.position.y - left.y, 0, left.y - self.bounds.end.y)
	).length_squared()
	var right_diff = Vector2(
		max(self.bounds.position.x - right.x, 0, right.x - self.bounds.end.x),
		max(self.bounds.position.y - right.y, 0, right.y - self.bounds.end.y)
	).length_squared()
	return sqrt(min(left_diff, right_diff))

func distance_to_point(point: Vector2):
	return Vector2(
		max(self.bounds.position.x - point.x, 0, point.x - self.bounds.end.x),
		max(self.bounds.position.y - point.y, 0, point.y - self.bounds.end.y)
	).length()

func snap_to_grid(note_position:Vector2):
	var rel_x = note_position.x / tempo
	return Vector2(
		(floor(rel_x) + snapped(fmod(rel_x, 1.0) - 0.5/self.rhythm, 1.0/self.rhythm)) * tempo,
		Func.snap_to_scale(note_position.y, self.log_scale)
	)
