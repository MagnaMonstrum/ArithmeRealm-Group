extends Control

# Controller for the chest math problem overlay.
# Handles open/close lifecycle, pausing, problem display,
# and text input validation.

var chest: Node
var paused_before_open := false
var target_answer: int = 0
var int_A: int = 0
var int_B: int = 0
var op_symbol := "+"
var rng := RandomNumberGenerator.new()

@onready var label: Label = $CanvasLayer/CenterContainer/PanelContainer/VBoxContainer/ProblemLabel
@onready var line_edit: LineEdit = $CanvasLayer/CenterContainer/PanelContainer/VBoxContainer/LineEdit
@onready var submit_button: Button = $CanvasLayer/CenterContainer/PanelContainer/VBoxContainer/SubmitButton
@onready var feedback_label: Label = $CanvasLayer/CenterContainer/PanelContainer/VBoxContainer/FeedbackLabel
@onready var sfx: AudioStreamPlayer = $CanvasLayer/Sfx

const SUCCESS_SFX := preload("res://project/sounds/success.ogg")
const INCORRECT_SFX := preload("res://project/sounds/incorrect.ogg")

func _ready():
	visible = false
	# Let UI process while the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_process_input(true)
	rng.randomize()
	if sfx:
		sfx.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)
	
	if line_edit:
		line_edit.text_submitted.connect(_on_text_submitted)
		line_edit.text_changed.connect(_on_text_changed)
	
	if feedback_label:
		feedback_label.text = ""
		feedback_label.modulate = Color.WHITE

func open(chest_node: Node, problem: Dictionary) -> void:
	self.chest = chest_node
	self.int_A = problem.get("a", 0)
	self.int_B = problem.get("b", 0)
	self.target_answer = problem.get("answer", int_A + int_B)
	op_symbol = problem.get("operator_symbol", "+")
	
	paused_before_open = get_tree().paused
	get_tree().paused = true
	
	# Set the problem text
	if label:
		label.text = "%d %s %d = ?" % [int_A, op_symbol, int_B]
	
	# Clear input and feedback
	if line_edit:
		line_edit.text = ""
	
	if feedback_label:
		feedback_label.text = ""
	
	self.visible = true
	
	# Grab focus after a frame to avoid capturing the 'E' key press
	await get_tree().process_frame
	if line_edit:
		line_edit.text = ""  # Clear again in case E was captured
		line_edit.grab_focus()

func close() -> void:
	get_tree().paused = paused_before_open
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _on_submit_pressed() -> void:
	_check_answer()

func _on_text_submitted(_text: String) -> void:
	_check_answer()

func _check_answer() -> void:
	if not line_edit:
		return
	
	var input_text = line_edit.text.strip_edges()
	
	if input_text.is_empty():
		if feedback_label:
			feedback_label.text = "Please enter an answer!"
			feedback_label.modulate = Color.YELLOW
		return
	
	var input_value = input_text.to_int()
	
	if input_value == target_answer:
		_on_correct_answer()
	else:
		_on_wrong_answer()

var _suppress_change := false
func _on_text_changed(new_text: String) -> void:
	if _suppress_change:
		return
	var digits := ""
	for c in new_text:
		if "0123456789".find(c) != -1:
			digits += c
	if digits != new_text:
		_suppress_change = true
		line_edit.text = digits
		line_edit.caret_column = digits.length()
		_suppress_change = false

func _on_correct_answer() -> void:
	if feedback_label:
		feedback_label.text = "Good job!"
		feedback_label.modulate = Color.GREEN

	# Play success sound
	if sfx:
		sfx.stop()
		sfx.stream = SUCCESS_SFX
		sfx.play()
	
	# Tell the chest to open
	if chest and chest.has_method("on_correct_answer"):
		chest.on_correct_answer()
	
	# Award 2-5 gems to the player
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player:
		var reward := rng.randi_range(2, 5)
		if player.has_method("_on_add_gem"):
			for i in range(reward):
				player._on_add_gem()

	# Wait for sound to finish before closing
	if sfx:
		await sfx.finished
	
	close()

func _on_wrong_answer() -> void:
	if feedback_label:
		feedback_label.text = "Uh oh, that was not right!"
		feedback_label.modulate = Color.RED

	# Play incorrect sound
	if sfx:
		sfx.stop()
		sfx.stream = INCORRECT_SFX
		sfx.play()
	
	# Tell the chest to fade away
	if chest and chest.has_method("on_wrong_answer"):
		chest.on_wrong_answer()
	
	# Wait for sound to finish before closing
	if sfx:
		await sfx.finished
	
	close()
