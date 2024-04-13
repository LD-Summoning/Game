extends CharacterBody2D

@export var speed = 90
@export var health = 100
@onready var _animation = $AnimatedSprite2D

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_damage(damage: int):
	health = health - damage
	
func signal_damage(damage: int):
	_on_damage(damage)

func get_health() -> int:
	return health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left"):
		_animation.stop()
		_animation.play("left_walk")
	if Input.is_action_just_released("left"):
		_animation.stop()
		_animation.play("idle")