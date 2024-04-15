extends Node2D


@export var velocity = Vector2(0, 0)
@export var damage = 1
@export var impact_audio_stream: AudioStream

@onready var _audio_player_node = preload("res://scenes/OneTimeAudioStreamPlayer2D.tscn")

func _ready():
	if self.has_node("AudioStreamPlayer2D"):
		self.get_node("AudioStreamPlayer2D").play()
		self.get_node("AudioStreamPlayer2D").play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta


func _on_body_entered(body):
	if body.has_node("Health"):
		body.get_node("Health").signal_damage(damage)
	if impact_audio_stream != null:
		var audio_player = _audio_player_node.instantiate()
		audio_player.position = position
		audio_player.stream = impact_audio_stream
		get_parent().add_child(audio_player)
	queue_free()
