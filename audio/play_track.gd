extends Button

var playback_notes = []

func _toggled(toggled_on):
	text = "⏸" if toggled_on else "▶"
	TrackData.is_playing = toggled_on
	playback_notes = TrackData.notes # .duplicate(true)
	if toggled_on:
		play_smf.emit(create_smf())
	else:
		play_smf.emit(create_pause_smf())

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

signal play_smf(smf:SMF)

func _pressed():
	pass

func create_smf( ) -> SMF.SMFData:
	var tempo:int = 60
	var events:Array[SMF.MIDIEventChunk] = []
	var tracks:Array[SMF.MIDITrack] = []
	
	events.append(SMF.MIDIEventChunk.new(0, 0, SMF.MIDIEventSystemEvent.new({
		"type": SMF.MIDISystemEventType.set_tempo,
		"bpm": 60000000. / tempo
	})))
	# added program change
	for i in range(0, 16):
		if i != 9:
			events.append(SMF.MIDIEventChunk.new(-1, i, SMF.MIDIEventProgramChange.new(70)))
	
	var channel_number = 0
	for note in playback_notes:
		# note on
		var start_time = note.note_on * TrackData.timebase
		var end_time = (note.note_on + note.duration) * TrackData.timebase
		var note_number = round(note.pitch * 12)
		events.append(SMF.MIDIEventChunk.new(start_time, channel_number, SMF.MIDIEventNoteOn.new(note_number, 127)))
		events.append(SMF.MIDIEventChunk.new(start_time, channel_number, SMF.MIDIEventPitchBend.new(8192 + 4096 * (note.pitch * 12 - round(note.pitch * 12)))))
		# note off (not support "note on with velocity 0 as note off" on Godot MIDI Player. It was converted on SMF.gd when *.mid read.)
		events.append(SMF.MIDIEventChunk.new(end_time, channel_number, SMF.MIDIEventNoteOff.new(note_number, 0)))
		
		channel_number = (channel_number + (2 if channel_number == 8 else 1)) % 16
	# if you generate *.mid using SMF.gd write function, needs End of Track.
	# but if only play on Godot MIDI Player, not needs End of Track.
	events.sort_custom(func(a, b): return a.time < b.time or (a.time == b.time and a.event.type < b.event.type))
		
	# "a.event.type < b.event.type" checks for: note off before note on 
	# events.append( SMF.MIDIEventChunk.new( time, 0, SMF.MIDIEventSystemEvent.new({ "type": SMF.MIDISystemEventType.end_of_track } ) ) )

	tracks.append(SMF.MIDITrack.new(0, events))
	return SMF.SMFData.new(SMF.SMFFormat.format_0, 1, TrackData.timebase, tracks)

func create_pause_smf() -> SMF.SMFData:
	var events:Array[SMF.MIDIEventChunk] = []
	var tracks:Array[SMF.MIDITrack] = []
	
	# added program change
	events.append(SMF.MIDIEventChunk.new(0, 0, SMF.MIDIEventProgramChange.new(0)))
	events.append(SMF.MIDIEventChunk.new(1, 0, SMF.MIDIEventSystemEvent.new({ "type": SMF.MIDISystemEventType.end_of_track } ) ) )
	tracks.append(SMF.MIDITrack.new(0, events))
	return SMF.SMFData.new(SMF.SMFFormat.format_0, 1, TrackData.timebase, tracks)

func _on_stop_button_halt_play_button():
	button_pressed = false
