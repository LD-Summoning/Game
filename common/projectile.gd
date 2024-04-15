extends Node2D


@export var velocity = Vector2(0, 0)
@export var damage = 1
@export var impact_audio_stream: AudioStream

func _ready():
	if self.has_node("AudioStreamPlayer2D"):
		self.get_node("AudioStreamPlayer2D").play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta


func _on_body_entered(body):
	if body.has_node("Health"):
		body.get_node("Health").signal_damage(damage)
	if body.has_node("ExternalAudioStreamPlayer") and impact_audio_stream != null:
		var audio_player = body.get_node("ExternalAudioStreamPlayer")
		audio_player.stream = impact_audio_stream
		audio_player.play()
	queue_free()
