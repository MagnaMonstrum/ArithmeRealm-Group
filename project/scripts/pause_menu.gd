extends Control

func _ready() -> void:
    process_mode = PROCESS_MODE_WHEN_PAUSED

func _on_resume_pressed() -> void:
    visible = false
    get_tree().paused = false