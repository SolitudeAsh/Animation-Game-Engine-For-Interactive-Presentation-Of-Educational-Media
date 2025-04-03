extends Node2D

@onready var color_array = $ColorArray
@onready var ui = $UI
@onready var array_controller = $ArrayController

func _ready():
	ui.start_pressed.connect(array_controller.start_sorting)
	ui.reset_pressed.connect(array_controller.reset_array)
	ui.speed_changed.connect(array_controller.set_speed)
	array_controller.score_updated.connect(ui.update_score)


# Add this to your Main.gd script
	# Set up UI colors
	for button in get_tree().get_nodes_in_group("buttons"):
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.4, 0.6, 1.0, 1.0)  # Light blue
		style.corner_radius_top_left = 5
		style.corner_radius_top_right = 5
		style.corner_radius_bottom_left = 5
		style.corner_radius_bottom_right = 5
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_color_override("font_color", Color.WHITE)
	
	# Set up labels
	for label in get_tree().get_nodes_in_group("labels"):
		label.add_theme_color_override("font_color", Color.WHITE)
