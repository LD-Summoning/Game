extends AudioStreamPlayer

var play_back: AudioStreamPlayback
@export var play_back_stream: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_finished():
	if play_back_stream != null:
		if play_back != null:
			play_back
		play_back_stream.instantiate_playback()
