extends Node2D

var main_scale = TrackData.scale
var track_dimensions = TrackData.track_dimensions

var view_scale = Vector2(6.0, 2.0)
var view_position = Vector2(0, 4)

var rect_width:float = 24
var pen_stroke_width:float = 1.0

var mouse_position:Vector2
var mouse_mapped_position:Vector2

var input_event:InputEvent

var is_inputting_notes = false
var is_editing_grids = false
var is_mouse_selecting = false

var mouse_on_note:Note = null # which note is the mouse on?
var mouse_on_grid:NoteGrid = null # which grid is the mouse on?

var mouse_note_margin = 0 # which note margin is the mouse dragging? 
# 0 = center (none), -1 = left, +1 = right

var is_relative_duration:bool = true 
# relative duration = how many beats
# absolute duration = how many seconds
# TODO function that toggles this with relevant conversion of cursor_duration

var selection_rect = Rect2()
var mouse_select_initial_point = Vector2()

var bounds = Rect2()
var view_transform = Transform2D() # transform 0~1 coordinates to screen coordinates
var view_transform_inverse = view_transform.affine_inverse()

var cursor_duration = 1/2.
# var note_minimum_duration = 1/256.

# Called when the node enters the scene tree for the first time.
func _ready():
	# sort notes
	# sort_notes(notes)
	# prepare scale
	main_scale = TrackData.scale
	main_scale.push_front(1)
	main_scale = main_scale.map(func(x): return log(x)/log(2))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# queue_redraw()
	pass

func _input(event):
	input_event = event
	queue_redraw()
	$"draw grids".redraw()
	$"draw notes".redraw()
	$"editing".redraw()

func _draw():
	bounds = get_viewport_rect().size
	mouse_position = get_viewport().get_mouse_position()
	
	view_transform.x.x = bounds.x / view_scale.x
	view_transform.y.y = -bounds.y / view_scale.y
	view_transform.origin = Vector2(0, bounds.y)
	
	view_transform = view_transform * Transform2D(Vector2(1, 0), Vector2(0, 1), -view_position)
	
	view_transform_inverse = view_transform.affine_inverse()
		
	# draw selection
	if is_mouse_selecting:
		selection_rect = view_transform * Rect2(
			mouse_select_initial_point, 
			mouse_mapped_position - mouse_select_initial_point
		)
		draw_rect(selection_rect, Color(Color.AQUA, 0.3))
	
	# draw frame
	draw_rect(Rect2(Vector2.ZERO, bounds), Color.BLACK, false, 2)

func constrain_view():
	var right_margin_abundance = (
		view_position + view_scale - track_dimensions).clamp(Vector2.ZERO, Vector2.INF)
	view_position = view_position - right_margin_abundance
	view_position = view_position.clamp(Vector2.ZERO, Vector2.INF)

func zoom(factor):
	var target = mouse_mapped_position
	view_scale = view_scale * factor
	view_scale = view_scale.clamp(Vector2.ZERO, track_dimensions)
	view_transform.x.x = bounds.x / view_scale.x
	view_transform.y.y = -bounds.y / view_scale.y
	view_transform.origin = Vector2(0, bounds.y)
	view_position = target - view_transform.affine_inverse() * mouse_position
	constrain_view()
	
var cursor_duration_num = 1
var cursor_duration_den = 4

func set_cursor_duration():
	if not(cursor_duration_num is int) or not (cursor_duration_den is int):
		cursor_duration_num = 0.25
	elif cursor_duration_num == 0 or cursor_duration_den == 0: 
		cursor_duration_num = 0.25
	else:
		cursor_duration = float(cursor_duration_num) / cursor_duration_den

func _on_edit_numerator_changed(num):
	if num != "":
		cursor_duration_num = int(num)
	set_cursor_duration()

func _on_edit_denominator_changed(den):
	if den != "":
		cursor_duration_den = int(den)
	set_cursor_duration()

func _on_import_scala_file_button_scale_changed():
	main_scale = TrackData.scale
	main_scale.push_front(1)
	main_scale = main_scale.map(func(x): return log(x)/log(2))

func _on_toggle_edit_note_button_toggled(toggled_on):
	is_inputting_notes = toggled_on
