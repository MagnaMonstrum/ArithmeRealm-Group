extends Control
@onready var dialog_line = %DialogLine
@onready var speaker_name = %SpeakerName

const ANIMATION_SPEED : int = 30
var animate_text : bool = false
var current_visible_characters : int = 0

func _process(delta: float) -> void:
	if animate_text:
		if dialog_line.visible_ratio < 1:
			dialog_line.visible_ratio += (1.0 / dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			current_visible_characters = dialog_line.visible_characters
		else:
			animate_text = false

func change_line(speaker: String, line : String) -> void:
	speaker_name.text = speaker
	current_visible_characters = 0
	dialog_line.text = line
	dialog_line.visible_characters = 0
	animate_text = true

func skip_text_animation() -> void:
	dialog_line.visible_ratio = 1
