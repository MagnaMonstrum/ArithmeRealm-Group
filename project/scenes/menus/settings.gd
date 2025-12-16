extends Control

func _ready() -> void:
	%Back.pressed.connect(play)
	# Update checkbox to match current state
	var is_fullscreen = SettingsManager.get_setting("display", "fullscreen", false)
	%CheckBox.button_pressed = is_fullscreen

func play() -> void:
	visible = false

func _on_check_box_toggled(toggled_on: bool) -> void:
	get_window().mode = Window.MODE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED
	SettingsManager.save_setting("display", "fullscreen", toggled_on)
