extends Node

const SETTINGS_FILE = "user://settings.cfg"
var config = ConfigFile.new()

func _ready() -> void:
    load_settings()

func load_settings() -> void:
    var err = config.load(SETTINGS_FILE)
    if err != OK:
        # File doesn't exist yet, use defaults
        pass

func get_setting(section: String, key: String, default_value):
    return config.get_value(section, key, default_value)

func save_setting(section: String, key: String, value) -> void:
    config.set_value(section, key, value)
    config.save(SETTINGS_FILE)