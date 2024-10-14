extends Node2D

@onready var p = get_parent()
@onready var g:NoteGrid

var selected_notes = []
var mouse_selection_pivot = Vector2() # which point (TODO replace with note) is the mouse dragging in a selection?
var selection_pivots = [] # save all the selected notes' data
var mouse_selected_position 

func _ready():
	pass

signal sample_note(note)
signal send_data_to_analysis(object_list)
# TODO fix note dragging behaviour (try preventing notes to be dragged beyond grid (in the normal case?))
func _input(event):
	g = find_nearest_grid(p.mouse_mapped_position)
	p.mouse_on_grid = g
	selected_notes = find_selected_notes(TrackData.notes)
	var snap = g.snap_to_grid(p.mouse_mapped_position)
		
	if event is InputEventMouseButton and event.pressed and event.button_index == 1: 
		# left mouse button pressed
		if p.is_inputting_notes and p.mouse_on_note == null:
			# inputting notes
			free_selection(selected_notes)
			
			var cursor_duration = p.cursor_duration
			if p.is_relative_duration:
				cursor_duration = cursor_duration * g.tempo
			
			add_note(snap.x, cursor_duration, snap.y)
		else:
			# not inputting notes
			mouse_selected_position = Vector2()
			if len(selected_notes) == 0 and p.mouse_on_note != null:
				# clicking on a note
				mouse_selection_pivot = Vector2(p.mouse_mapped_position)
				mouse_selected_position = Vector2(p.mouse_on_note.note_on, p.mouse_on_note.pitch)
				p.mouse_on_note.selected = true
				sample_note.emit(Note.new(0, 0.4, p.mouse_on_note.pitch, false))
			if len(selected_notes) == 0 and p.mouse_on_note == null:
				# clicking on nothing, start selecting
				p.is_mouse_selecting = true
				p.mouse_select_initial_point = p.mouse_mapped_position
			if len(selected_notes) != 0 and p.mouse_on_note == null:
				# nothing moved. reselect
				p.is_mouse_selecting = true
				p.mouse_select_initial_point = p.mouse_mapped_position
			if len(selected_notes) != 0 and p.mouse_on_note != null and p.mouse_on_note not in selected_notes:
				# clicked another note not in selection
				mouse_selection_pivot = Vector2(p.mouse_mapped_position)
				mouse_selected_position = Vector2(p.mouse_on_note.note_on, p.mouse_on_note.pitch)
				p.is_mouse_selecting = false
				sample_note.emit(Note.new(0, 0.4, p.mouse_on_note.pitch, false))
				# free all selected notes
				free_selection(selected_notes)
				p.mouse_on_note.selected = true
			if len(selected_notes) != 0 and p.mouse_on_note != null and p.mouse_on_note in selected_notes:
				# clicking on a selected note
				mouse_selection_pivot = Vector2(p.mouse_mapped_position)
				mouse_selected_position = Vector2(p.mouse_on_note.note_on, p.mouse_on_note.pitch)
				sample_note.emit(Note.new(0, 0.4, p.mouse_on_note.pitch, false))
				
		selected_notes = find_selected_notes(TrackData.notes)
		selection_pivots = duplicate_note_list(selected_notes)
	
	if event is InputEventMouseButton and not(event.pressed) and event.button_index == 1: 
		# left mouse button released 
		p.is_mouse_selecting = false
		p.selection_rect = Rect2()
		rectify_notes_with_negative_duration(selected_notes)
		send_data_to_analysis.emit(selected_notes)
	
	if event is InputEventMouseMotion and event.button_mask == 1:
		# mouse moved holding left button
		if not p.is_mouse_selecting and len(selected_notes) != 0:
			var dragging_difference = p.mouse_mapped_position - mouse_selection_pivot
			match p.mouse_note_margin:
				0: # dragging a selection
					dragging_difference = g.snap_to_grid(dragging_difference + mouse_selected_position) - mouse_selected_position
					for i in range(len(selected_notes)):
						selected_notes[i].note_on = selection_pivots[i].note_on + dragging_difference.x
						selected_notes[i].pitch = selection_pivots[i].pitch + dragging_difference.y
				-1:
					dragging_difference = g.snap_to_grid(dragging_difference + mouse_selected_position) - mouse_selected_position
					for i in range(len(selected_notes)):
						selected_notes[i].note_on = selection_pivots[i].note_on + dragging_difference.x
						selected_notes[i].duration = selection_pivots[i].duration - dragging_difference.x
				1:
					for i in range(len(selected_notes)):
						var _x_ = selection_pivots[i].note_on + selection_pivots[i].duration + dragging_difference.x
						selected_notes[i].duration = g.snap_to_grid(Vector2(_x_, 0)).x - selection_pivots[i].note_on
	
	if event is InputEventMouseMotion and event.button_mask == 2: 
		# mouse moved holding right button
		# move view
		var movement = event.relative * p.view_scale / p.bounds
		movement.x = -movement.x
		p.view_position = p.view_position + movement
		p.view_position = p.view_position.clamp(Vector2(0, 0), p.view_position)
		p.constrain_view()
		
	if event is InputEventMouseButton and event.button_index == 4 and event.button_mask == 0:
		if event.is_ctrl_pressed():
			p.zoom(Vector2(1, 1/1.1))
		else:
			p.zoom(1/1.1)
		
	if event is InputEventMouseButton and event.button_index == 5 and event.button_mask == 0:
		if event.is_ctrl_pressed():
			p.zoom(Vector2(1, 1.1))
		else:
			p.zoom(1.1)
	
	if event is InputEventKey and event.pressed == true:
		match event.is_ctrl_pressed():
			false: match event.keycode:
				4194312: delete_selection() # delete key
				81: half_beats()
				87: double_beats()
				86: select_vertical()
			true: match event.keycode:
				67: TrackData.copied_notes = selected_notes
				86: paste_notes(TrackData.copied_notes, snap)
	# print(event)
	queue_redraw()

func _draw():
	# draw cursor 
	if g != null:
		p.mouse_mapped_position = p.view_transform_inverse * p.mouse_position
		var draw_cursor_position = g.snap_to_grid(p.mouse_mapped_position)
		var cursor_screen_position = p.view_transform * draw_cursor_position
		if p.is_inputting_notes:
			var cursor_duration = p.cursor_duration
			if p.is_relative_duration:
				cursor_duration = cursor_duration * g.tempo
			var cursor_length = (
					p.view_transform * Vector2(cursor_duration, 0) - p.view_transform * Vector2(0, 0)
				).x
			var cursor = Rect2(
				cursor_screen_position.x, cursor_screen_position.y - p.rect_width/2.0, 
				cursor_length, p.rect_width
			)
			draw_rect(cursor, Color(Color.AQUA, 0.5))
			
	# draw crosshair for the note selected
		var note_selected_position = p.view_transform * draw_cursor_position
		draw_line(Vector2(0, note_selected_position.y), Vector2(p.bounds.x, note_selected_position.y), Color.RED, 3)
		# pitch label
		draw_string(ThemeDB.fallback_font, Vector2(0, note_selected_position.y - 3), String.num(draw_cursor_position.y, 5), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.RED)
		draw_line(Vector2(note_selected_position.x, 0), Vector2(note_selected_position.x, p.bounds.y), Color.RED, 3)
		# time label
		draw_string(ThemeDB.fallback_font, Vector2(note_selected_position.x, 16), String.num(draw_cursor_position.x, 5), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.RED)


func find_selected_notes(note_list):
	return note_list.filter(func(note): return note.selected) 

func free_selection(note_list):
	for note in note_list: 
		if note.duration < 0: # retrovert note if duration less than 0
			note.note_on = note.note_on + note.duration
			note.duration = -note.duration
		if note.duration != 0: # delete note if duration is 0
			note.selected = false 
	delete_selection()

func add_note(note_on, duration, pitch, selected = false):
	TrackData.notes.append(Note.new(note_on, duration, pitch, selected))

func duplicate_note_list(note_list):
	var result = []
	for note in note_list:
		result.append(note.copy())
	return result


func half_beats():
	g.rhythm = g.rhythm*2
	p.cursor_duration = 1/g.rhythm

func double_beats():
	g.rhythm = g.rhythm/2
	p.cursor_duration = 1/g.rhythm

func delete_selection():
	TrackData.notes = TrackData.notes.filter(func(note): return not note.selected)

func select_vertical(fix_point = false):
	if fix_point:
		pass
	else:
		for note in TrackData.notes:
			for selected_note in selected_notes:
				var a = note.note_on < selected_note.note_on + selected_note.duration
				var b = selected_note.note_on < note.note_on + note.duration
				if a and b:
					note.selected = true

func paste_notes(note_list, offset):
	free_selection(TrackData.notes)
	var first = first_note(note_list)
	for note in note_list:
		add_note(
			note.note_on - first.note_on + offset.x, 
			note.duration, 
			note.pitch - first.pitch + offset.y,
			true
		)

func rectify_notes_with_negative_duration(note_list):
	for note in note_list:
		if note.duration < 0:
			note.note_on = note.note_on + note.duration
			note.duration = -1 * note.duration

func first_note(note_list):
	sort_notes(note_list)
	return note_list[0] if len(note_list) != 0 else null
	
func sort_notes(note_list):
	note_list.sort_custom(note_order)
	
func note_order(a, b):
	var o = a.note_on <= b.note_on
	if a.note_on == b.note_on:
		o = a.pitch > b.pitch
	return o

func find_nearest_grid(point:Vector2) -> NoteGrid:
	if len(TrackData.grids) == 0:
		return null # nothing's here!
	else:
		var min_distance = INF
		var grid_with_min_distance = null
		for grid in TrackData.grids:
			var d = grid.distance_to_point(point)
			if d < min_distance:
				min_distance = d
				grid_with_min_distance = grid
		return grid_with_min_distance

func redraw():
	queue_redraw()
	pass
