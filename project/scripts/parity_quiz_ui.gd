extends Control

signal add_gem
signal solved

const CORRECT_SFX := preload("res://project/sounds/correct.ogg")
const INCORRECT_SFX := preload("res://project/sounds/incorrect.ogg")

var paused_before_open := false
var target_answer := 0
var rng := RandomNumberGenerator.new()

@onready var prompt_label: Label = $CanvasLayer/Panel/VBoxContainer/PromptLabel
@onready var feedback_label: Label = $CanvasLayer/Panel/VBoxContainer/FeedbackLabel
@onready var even_button: Button = $CanvasLayer/Panel/VBoxContainer/Buttons/EvenButton
@onready var odd_button: Button = $CanvasLayer/Panel/VBoxContainer/Buttons/OddButton
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_process_unhandled_input(true)
	rng.randomize()
	if sfx:
		sfx.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	even_button.pressed.connect(func() -> void:
		_check_choice(true)
	)
	odd_button.pressed.connect(func() -> void:
		_check_choice(false)
	)

func open() -> void:
	paused_before_open = get_tree().paused
	get_tree().paused = true
	visible = true
	_make_problem()

func close() -> void:
	get_tree().paused = paused_before_open
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
		accept_event()

func _make_problem() -> void:
	var problem := ProblemGenerator.make_problem(Global.current_level)
	target_answer = int(problem.get("answer", 0))
	var label := String(problem.get("label", "0 + 0"))
	prompt_label.text = "Is het antwoord van %s even of oneven?" % label
	feedback_label.text = ""
	_set_buttons_enabled(true)

func _check_choice(picked_even: bool) -> void:
	var is_even := target_answer % 2 == 0
	if picked_even == is_even:
		var gem_reward := rng.randi_range(1, 5)
		feedback_label.modulate = Color(0.35, 1.0, 0.55)
		feedback_label.text = "Goed gedaan!"
		_set_buttons_enabled(false)
		_play_sfx(CORRECT_SFX)
		for i in range(gem_reward):
			emit_signal("add_gem")
		emit_signal("solved")
		await _await_duration_while_paused(0.9)
		close()
	else:
		feedback_label.modulate = Color(1.0, 0.45, 0.45)
		feedback_label.text = "Niet helemaal. Probeer opnieuw!"
		_play_sfx(INCORRECT_SFX)

func _set_buttons_enabled(enabled: bool) -> void:
	even_button.disabled = not enabled
	odd_button.disabled = not enabled

func _play_sfx(stream: AudioStream) -> void:
	if not sfx:
		return
	sfx.stop()
	sfx.stream = stream
	sfx.play()

func _await_duration_while_paused(seconds: float) -> void:
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = seconds
	t.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(t)
	t.start()
	await t.timeout
	t.queue_free()
