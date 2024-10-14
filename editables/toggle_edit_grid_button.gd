extends Button

func _toggled(toggled_on):
	# TODO use signals to avoid going up and down the tree
	$"../../../../notes/VBoxContainer/SubViewportContainer/SubViewport (everything else)/visualizer".is_editing_grids = toggled_on
	text = "edit grids" if toggled_on else "edit notes"

func _input(event):
	if event is InputEventKey and event.pressed == true:
		match event.keycode:
			71: button_pressed = not(button_pressed)
