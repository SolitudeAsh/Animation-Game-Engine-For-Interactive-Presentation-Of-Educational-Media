extends Node2D

@onready var csv_export = preload("res://CSVExport.gd").new()
@onready var ui = $UI
@onready var array_controller = $ArrayController

var player_name = ""  # Store player name

func _ready():
	call_deferred("_connect_signals")
	csv_export.export_to_csv()

func _connect_signals():
	ui.reset_pressed.connect(array_controller.reset_array)
	ui.check_solution_pressed.connect(array_controller.check_solution)
	ui.name_entered.connect(_on_name_entered)  # Receive name from UI
	array_controller.score_updated.connect(ui.update_score)
	array_controller.solution_checked.connect(_on_solution_checked)

func _on_name_entered(name: String):
	player_name = name
	print("🎮 Game started for player:", player_name)

func _on_solution_checked(is_correct: bool):
	var result_message = "Correct! The colors are properly sorted!" if is_correct else "Not quite right. Keep trying!"
	csv_export.record_score(player_name, array_controller.score, result_message)
	csv_export.export_to_csv()
	ui.show_result(is_correct)
