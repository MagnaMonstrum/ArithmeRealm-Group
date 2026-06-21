extends CharacterBody2D

@onready var interactable := $Interactable
@onready var dialog_ui = %DialogUI
@onready var next_button = %Next

var dialog_index: int = 0;

const dialog_lines: Array[String] = [
	"Prof Sum: Hallo, mijn naam is Professor Sum. Ik ben een blob-geleeerde. Ik heb jouw hulp nodig.",
	"Prof Sum: De Blobs zijn zwak en hongerig, en de vloek van Bad Mathic wordt alleen maar sterker.",
	"Prof Sum: De enige manier om de wereld te redden, is door de juiste antwoorden terug te brengen naar de juiste Blobs.",
	"Prof Sum: Elke keer dat je een Blob het juiste getal voert, breek je een klein stukje van de vloek. Als dank laten ze een glinsterende gem vallen: een stukje pure rekenmagie. Verzamel je genoeg gems, dan opent er een portaal naar het volgende gebied.",
]

func _ready() -> void:
	process_mode = PROCESS_MODE_WHEN_PAUSED
	interactable.interact = _on_interact
	interactable.interaction_name = "Druk op E om te praten"
	next_button.pressed.connect(Next)
	dialog_index = 0
	process_current_line()

func _on_interact() -> void:
	get_tree().paused = true
	dialog_ui.show()
	next_button.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("previous_line"):
		if dialog_index > 0:
			dialog_index -= 1
			process_current_line()

func parse_line(line: String) -> Dictionary:
	var line_info = line.split(":")
	assert(len(line_info) >= 2)
	return {
		"speaker_name": line_info[0],
		"dialog_line": line_info[1]
	}

func process_current_line() -> void:
	var line = dialog_lines[dialog_index]
	var line_info = parse_line(line)
	dialog_ui.change_line(line_info["speaker_name"], line_info["dialog_line"])


func Next() -> void:
	if dialog_ui.animate_text:
		dialog_ui.skip_text_animation()
	else:
		if dialog_index < len(dialog_lines) - 1:
			dialog_index += 1
			process_current_line()
		else:
			get_tree().paused = false
			dialog_ui.hide()
			next_button.hide()
