extends Button

func _toggled(toggled_on):
	text = "select notes" if toggled_on else "edit notes"

func _input(event):
	if event is InputEventKey and event.pressed == true:
		match event.keycode:
			78: button_pressed = not(button_pressed)
