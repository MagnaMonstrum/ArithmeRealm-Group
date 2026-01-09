extends Node2D

const BASE_TEXTURE := preload("res:///art/sprites/characters/blob_sum.png")
const SAD_TEXTURE := preload("res:///art/sprites/characters/blob_wrong.png")
const CORRECT_SFX := preload("res:///sounds/correct.ogg")
const INCORRECT_SFX := preload("res:///sounds/incorrect.ogg")
const SAD_DURATION := 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer

var _state_version := 0
var _base_texture: Texture2D = BASE_TEXTURE

func _ready() -> void:
	# Keep reacting while the game is paused (Problem UI pauses the tree)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# Cache the starting texture so we can restore it after reactions.
	if sprite and sprite.texture:
		_base_texture = sprite.texture
	if sfx:
		sfx.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func play_wrong_animation() -> void:
	# Show sad face and play incorrect sound for a few seconds, then revert.
	_state_version += 1
	var version = _state_version
	_set_texture(SAD_TEXTURE)
	_play_sound(INCORRECT_SFX)
	# Timer that runs while paused
	await _await_duration_while_paused(SAD_DURATION)
	if version == _state_version:
		_set_texture(_base_texture)

func play_correct_animation() -> void:
	# Ensure happy face and play correct sound, then let caller proceed.
	_state_version += 1
	_set_texture(_base_texture)
	if sfx:
		sfx.stop()
		sfx.stream = CORRECT_SFX
		sfx.play()
		await sfx.finished
	else:
		await _await_duration_while_paused(0.2)

func _await_duration_while_paused(seconds: float) -> void:
	# Local Timer that processes while paused
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = seconds
	t.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(t)
	t.start()
	await t.timeout
	t.queue_free()

func _set_texture(tex: Texture2D) -> void:
	if sprite:
		sprite.texture = tex

func _play_sound(stream: AudioStream) -> void:
	if not sfx:
		return
	sfx.stop()
	sfx.stream = stream
	sfx.play()
