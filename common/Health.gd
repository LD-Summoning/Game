extends Node

@export var _health = 100
@export var _invincible = 0


func _on_damage(damage: int):
	_health = _health - damage
	print("Took damage: "+str(damage))


func signal_damage(damage: int):
	if _invincible > 0:
		return
	_on_damage(damage)


func get_health() -> int:
	return _health


func add_invinicibility():
	_invincible += 1
	
func revoke_invincibility():
	assert(_invincible >= 0)
	if _invincible == 0:
		return
	_invincible -= 1
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
