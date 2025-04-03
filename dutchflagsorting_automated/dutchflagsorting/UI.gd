extends Control

signal start_pressed
signal reset_pressed
signal speed_changed(value: float)

@onready var start_button = $StartButton
@onready var reset_button = $ResetButton
@onready var speed_slider = $SpeedSlider
@onready var score_label = $ScoreLabel

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	speed_slider.value_changed.connect(_on_speed_changed)

func _on_start_pressed():
	emit_signal("start_pressed")

func _on_reset_pressed():
	emit_signal("reset_pressed")

func _on_speed_changed(value):
	emit_signal("speed_changed", value)

func update_score(score: int):
	score_label.text = "Score: %d" % score
