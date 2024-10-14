extends Node

@onready var input_event:InputEventMIDI = InputEventMIDI.new()
@onready var channel_number = 0
@onready var sample_note_duration = 0.5

func _ready():
	pass

func _process(_delta):
	TrackData.current_play_time = $MidiPlayer.position / TrackData.timebase

func _on_play_button_play_smf(smf):
	$MidiPlayer.smf_data = smf
	$MidiPlayer.play()

func _on_editing_sample_note(note):
	var events:Array[SMF.MIDIEventChunk] = []
	var tracks:Array[SMF.MIDITrack] = []
	
	# added program change / $03 Honky Tonk Piano
	events.append(SMF.MIDIEventChunk.new(0, 0, SMF.MIDIEventProgramChange.new(0)))
	var note_number = round(note.pitch * 12)
	events.append(SMF.MIDIEventChunk.new(0, channel_number, SMF.MIDIEventNoteOn.new(note_number, 127)))
	events.append(SMF.MIDIEventChunk.new(0, channel_number, SMF.MIDIEventPitchBend.new(8192 + 4096 * (note.pitch * 12 - round(note.pitch * 12)))))
	# note off (not support "note on with velocity 0 as note off" on Godot MIDI Player. It was converted on SMF.gd when *.mid read.)
	events.append(SMF.MIDIEventChunk.new(sample_note_duration * TrackData.timebase, channel_number, SMF.MIDIEventNoteOff.new(note_number, 0)))
	
	channel_number = (channel_number + (2 if channel_number == 8 else 1)) % 16
	events.append(SMF.MIDIEventChunk.new(1, 0, SMF.MIDIEventSystemEvent.new({ "type": SMF.MIDISystemEventType.end_of_track } ) ) )
	tracks.append(SMF.MIDITrack.new(0, events))
	$MidiPlayer.smf_data = SMF.SMFData.new(SMF.SMFFormat.format_0, 1, TrackData.timebase, tracks)
	$MidiPlayer.play()
