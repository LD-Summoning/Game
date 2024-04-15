extends Node

@export var leadup_music: AudioStream
@export var loop_music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	var leadup_audio_player = get_parent().get_parent().get_node("LeadupPlayer")
	leadup_audio_player.stream = leadup_music
	leadup_audio_player.stop()
	var playback_audio_player = get_parent().get_parent().get_node("PlaybackPlayer")
	playback_audio_player.stop()
	loop_music.loop = true
	playback_audio_player.stream = loop_music
	leadup_audio_player.play()
