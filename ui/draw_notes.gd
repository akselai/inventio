extends Node2D

var p = get_parent()
var block_width

func _ready():
	p = get_parent()

func redraw():
	queue_redraw()
	pass

func _draw():
	block_width = (p.view_transform_inverse * Vector2(0, 0) - p.view_transform_inverse * Vector2(0, p.rect_width)).y
	
	# draw notes
	p.mouse_on_note = null
	for note in TrackData.notes:
		var note_rect = p.view_transform * Rect2(
			note.note_on, note.pitch - block_width/2.0, 
			note.duration, block_width
		)
		var rect_color
		if (note_rect.has_point(p.mouse_position)): # mouse over?
			rect_color = Color(Color.GRAY, 1)
			if p.mouse_on_note == null:
				p.mouse_on_note = note
		else:
			rect_color = Color(Color.WEB_GRAY, 1)
		if p.is_mouse_selecting:
			if (p.selection_rect.intersects(note_rect)): # selected?
				rect_color = Color(Color.YELLOW, 1)
				note.selected = true
			else:
				note.selected = false
		else:
			if note.selected: # selected?
				rect_color = Color(Color.YELLOW, 1)
		draw_rect(note_rect, rect_color)
		
		# draw dragging note margin
		
		var margin_width = p.rect_width / p.view_transform.x.x
		margin_width = min(margin_width, abs(note.duration) / 3) * sign(note.duration)
		var left_note_margin = p.view_transform * Rect2(
			note.note_on, note.pitch - block_width/2.0, 
			margin_width, block_width
		)
		var right_note_margin = p.view_transform * Rect2(
			note.note_on + note.duration - margin_width, note.pitch - block_width/2.0, 
			margin_width, block_width
		)
		var mouse_is_dragging = p.input_event is InputEventMouseMotion and p.input_event.button_mask == 1
		# update variable. this is a part that would belong in input.gd but placed here for nicer code.
		if p.mouse_on_note == note and not mouse_is_dragging:
			p.mouse_note_margin = 0
			if left_note_margin.has_point(p.mouse_position):
				p.mouse_note_margin = -1
			if right_note_margin.has_point(p.mouse_position):
				p.mouse_note_margin = 1
		# finally draw margin
		if (p.mouse_on_note == note or note.selected) and not p.is_mouse_selecting:
			if p.mouse_note_margin == -1 and (
				mouse_is_dragging or left_note_margin.has_point(p.mouse_position)
			):
				draw_rect(left_note_margin, Color(Color.RED, 0.5))
			if p.mouse_note_margin == 1 and (
				mouse_is_dragging or right_note_margin.has_point(p.mouse_position)
			):
				draw_rect(right_note_margin, Color(Color.RED, 0.5))
		
		# that's a lot of if statements. I hope I won't have to fix this later.
