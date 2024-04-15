extends AudioStreamPlayer

func _ready():
	stream.loop = true

func _on_leadup_player_finished():
	play()
