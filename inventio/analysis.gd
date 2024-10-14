extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_editing_send_data_to_analysis(object_list):
	for child in get_children():
		child.queue_free() # remove all children
	
	if len(object_list) == 1:
		var note = object_list[0]
		var keyval_pairs = {"Start Time": note.note_on, "Duration": note.duration, "Pitch": note.pitch}
		var vbox_node = VBoxContainer.new()
		add_child(vbox_node)
		for t in ["Start Time", "Duration", "Pitch"]:
			var label_box_pair_node = HBoxContainer.new()
			label_box_pair_node.alignment = HORIZONTAL_ALIGNMENT_CENTER
			var label_node = Label.new()
			label_node.text = t
			label_node.size_flags_horizontal = Control.SIZE_EXPAND
			var box_node = LineEdit.new()
			box_node.text = String.num(keyval_pairs[t], 3)
			box_node.custom_minimum_size.x = 70
			# for usage of connect function, see https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-connect
			box_node.text_changed.connect(_on_box_node_text_changed.bind(t, object_list))
			
			vbox_node.add_child(label_box_pair_node)
			label_box_pair_node.add_child(label_node)
			label_box_pair_node.add_child(box_node)

func _on_box_node_text_changed(text, identifier, object_list):
	if len(object_list) == 1:
		if text.is_valid_float():
			text = float(text)
			var note = object_list[0]
			match identifier:
				"Start Time": note.note_on = text
				"Duration": note.duration = text
				"Pitch": note.pitch = text
