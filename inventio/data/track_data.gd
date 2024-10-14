extends Node

var track_dimensions = Vector2(16.0, 8.0)

var grids = [
]

var notes = [
]

var copied_notes = [
]

var base_frequency = 262.0
var base_frequency_position = 4.0

# var scale = [16/15., 9/8., 6/5., 5/4., 4/3., 45/32., 3/2., 8/5., 5/3., 9/5., 15/8., 2/1.]
var scale = [10/9., 5/4., 4/3., 3/2., 5/3., 15/8., 2/1.]

var timebase:int = 720  # quarter note = 720 = 2^4 * 3^2 * 5

var start_play_time = 0.0
var current_play_time = -INF

var is_playing = false

func _ready():
	for i in range(0):
		pass

# AGENDA 
''' 
Add toolbar (the File etc. buttons at the very top) - done, using menubar
- make the buttons functional
Add (draggable panel) inspector menu, default at the right - done, using dockable plugin
- add selection info (done (prelim?) have it recognize types? how many does it recognize? only note and grid?)
Also make the play options at the bottom draggable - done, using dockable plugin

Set the theme to something prettier

Eliminate track_data.gd in favor of a Track object
'''
