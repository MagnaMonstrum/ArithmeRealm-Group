extends Control

@onready var question_label: Label = $VBox/QuestionLabel
@onready var answer_input: LineEdit = $VBox/AnswerInput
@onready var submit_button: Button = $VBox/HBox/SubmitButton
@onready var next_button: Button = $VBox/HBox/NextButton
@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var score_label: Label = $VBox/ScoreLabel
@onready var difficulty_option: OptionButton = $VBox/TopBar/DifficultyOption

var correct_answer: float = 0.0
var score: int = 0
var total: int = 0
var max_number: int = 20

func _ready() -> void:
	%Back.pressed.connect(back)

	submit_button.pressed.connect(_on_submit)
	next_button.pressed.connect(_on_next)
	answer_input.text_submitted.connect(func(_t): _on_submit())
	difficulty_option.item_selected.connect(_on_difficulty_changed)

	difficulty_option.add_item("Makkelijk (1–10)")
	difficulty_option.add_item("Gemiddeld (1–50)")
	difficulty_option.add_item("Moeilijk (1–100)")
	difficulty_option.select(0)

	_generate_question()

func _on_difficulty_changed(index: int) -> void:
	match index:
		0: max_number = 10
		1: max_number = 50
		2: max_number = 100
	score = 0
	total = 0
	_update_score()
	_generate_question()

func _generate_question() -> void:
	var ops = ["+", "−", "×", "÷"]
	var op = ops[randi() % ops.size()]
	var a: int
	var b: int

	match op:
		"+":
			a = randi_range(1, max_number)
			b = randi_range(1, max_number)
			correct_answer = a + b
		"−":
			a = randi_range(1, max_number)
			b = randi_range(1, a)
			correct_answer = a - b
		"×":
			a = randi_range(1, mini(max_number, 12))
			b = randi_range(1, mini(max_number, 12))
			correct_answer = a * b
		"÷":
			b = randi_range(1, mini(max_number, 12))
			a = b * randi_range(1, mini(max_number, 12))
			correct_answer = a / b

	question_label.text = "%d %s %d = ?" % [a, op, b]
	answer_input.text = ""
	answer_input.editable = true
	feedback_label.text = ""
	submit_button.disabled = false
	next_button.visible = false
	answer_input.grab_focus()

func _on_submit() -> void:
	var user_text = answer_input.text.strip_edges()
	if user_text.is_empty():
		return

	if not user_text.is_valid_float():
		feedback_label.text = "Vul een getal in."
		feedback_label.add_theme_color_override("font_color", Color.YELLOW)
		return

	total += 1
	var user_answer = user_text.to_float()

	if is_equal_approx(user_answer, correct_answer):
		score += 1
		feedback_label.text = "Correct!"
		feedback_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		feedback_label.text = "Fout - antwoord was " + str(correct_answer)
		feedback_label.add_theme_color_override("font_color", Color.TOMATO)

	answer_input.editable = false
	submit_button.disabled = true
	next_button.visible = true
	next_button.grab_focus()
	_update_score()

func _on_next() -> void:
	_generate_question()

func _update_score() -> void:
	if total == 0:
		score_label.text = "Score: 0 / 0"
	else:
		var pct = int(round(float(score) / total * 100))
		score_label.text = "Score: %d / %d  (%d%%)" % [score, total, pct]

func back() -> void:
	get_tree().change_scene_to_file("res://project/scenes/menus/main_menu.tscn")