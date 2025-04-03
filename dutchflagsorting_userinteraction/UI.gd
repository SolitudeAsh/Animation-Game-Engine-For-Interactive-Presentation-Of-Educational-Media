extends Control

signal reset_pressed
signal check_solution_pressed
signal name_entered(name: String)

@onready var reset_button = $ResetButton
@onready var check_button = $CheckButton
@onready var score_label = $ScoreLabel
@onready var result_label = $ResultLabel
@onready var name_input = $NameInput  # Input field for player name

var player_name = ""

func _ready():
	reset_button.disabled = true
	check_button.disabled = true
	
	reset_button.pressed.connect(_on_reset_pressed)
	check_button.pressed.connect(_on_check_pressed)
	name_input.text_submitted.connect(_on_name_entered)  # Detect when Enter is pressed

func _on_name_entered(name: String):
	if name.strip_edges() == "":
		result_label.text = "⚠️ Please enter your name before playing."
		result_label.modulate = Color.RED
		return
	
	player_name = name.strip_edges()
	emit_signal("name_entered", player_name)
	
	name_input.hide()  # Hide input field after name is entered
	reset_button.disabled = false
	check_button.disabled = false
	
	result_label.text = "Welcome, %s! Start playing." % player_name
	result_label.modulate = Color.WHITE

func _on_reset_pressed():
	emit_signal("reset_pressed")
	result_label.text = ""

func _on_check_pressed():
	emit_signal("check_solution_pressed")

func update_score(score: int):
	score_label.text = "Moves: %d" % score

func show_result(is_correct: bool):
	if is_correct:
		result_label.text = "✅ Correct! The colors are properly sorted!"
		result_label.modulate = Color.GREEN
	else:
		result_label.text = "❌ Not quite right. Keep trying!"
		result_label.modulate = Color.RED
