extends Node

@export var music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	var audio_player = get_parent().get_node("AudioStreamPlayer")
	audio_player.stream = music
	audio_player.play()
