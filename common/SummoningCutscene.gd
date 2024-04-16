extends RichTextLabel


@export var summoning_timer: Timer
@export var appear_timer: Timer
@export var cutscene_casters: Node
@export var summoning_circle_sprite: Sprite2D
@export var player_sprite: AnimatedSprite2D

@onready var player = get_tree().get_nodes_in_group("player")[0]

const before_summoning = [
	"Cultist 1: The time has come. Prepare yourself.",
	"Cultist 2: Time for what, exactly?",
	"Cultist 1: [i]sighs[/i] You have to stand there. Everyone in position?",
	"Cult Leader: Everything is going to change. We will summon the most powerful creature of …",
	"… summonable creatures.  "]

# Commence ...

const while_summoning = [
	"You: Blub blub blub blub??",
	"Cult Leader: Now, Wet One. RISE!",
	"You: [i]angry[/i] Blub blub blub",
	"Cult Leader: I SAID, RIIIIIISEEE!",
	"Cultist 2: Well, that was a wet mistake",
	"Cult leader: Flee before you get wet!"
]

var has_summoned = false
var current_message = 0
var message_progress = 0
var done = false

func _process(delta):
	if !done:
		var current_message_array
		if has_summoned:
			current_message_array = while_summoning
		else:
			current_message_array = before_summoning
		var message_text = current_message_array[current_message]
		message_progress = min(message_progress + 1, message_text.length())
		var animated_message_text = message_text.substr(0, message_progress)
		text = animated_message_text
		if message_progress == message_text.length():
			if Input.is_action_just_pressed("next_message"):
				next_message(current_message_array)


func next_message(current_message_array):
	current_message += 1
	message_progress = 0
	if current_message == current_message_array.size():
		if !has_summoned:
			summon_player()
			done = true
			get_parent().hide()
			return
		else:
			cutscene_casters.queue_free()
			player.active = true
			get_parent().queue_free()


func summon_player():
	summoning_timer.start()
	appear_timer.start()
	cutscene_casters.get_node("Boss").play("attacking")
	summoning_circle_sprite.show()


func _on_summoning_timer_timeout():
	done = false
	has_summoned = true
	current_message = 0
	message_progress = 0
	get_parent().show()
	summoning_circle_sprite.hide()
	player_sprite.hide()
	player.show()


func _on_appear_timer_timeout():
	player_sprite.show()
