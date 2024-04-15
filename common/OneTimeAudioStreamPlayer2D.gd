extends AudioStreamPlayer2D


func _ready():
	super.play()


func _on_finished():
	super.stop()
	queue_free()
