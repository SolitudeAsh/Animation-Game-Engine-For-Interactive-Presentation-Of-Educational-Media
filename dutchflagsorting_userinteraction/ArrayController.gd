extends Node

signal score_updated(score: int)
signal solution_checked(is_correct: bool)

var array: Array = []
var score: int = 0
var selected_index: int = -1

@onready var color_array = $"../ColorArray"

func _ready():
	reset_array()

func reset_array():
	array.clear()
	score = 0
	selected_index = -1
	for i in range(10):
		array.append(randi() % 3)
	update_display()
	emit_signal("score_updated", score)
		
func update_display():
	for child in color_array.get_children():
		child.queue_free()  # Properly free all existing child nodes

	for i in range(array.size()):
		# Create a container for the colored box and outline
		var container = Control.new()
		container.size = Vector2(54, 54)  # Slightly larger to show the border clearly
		container.position = Vector2(i * 60 + 100, 200)

		# Create the outline as a Panel node
		var outline = Panel.new()
		outline.size = Vector2(54, 54)
		var style = get_outline_style(i)
		var theme = Theme.new()
		theme.set_stylebox("panel", "Panel", style)
		outline.theme = theme
		container.add_child(outline)

		# Create the colored box
		var rect = ColorRect.new()
		rect.size = Vector2(50, 50)
		rect.position = Vector2(2, 2)  # Center it inside the outline
		match array[i]:
			0: rect.color = Color.RED
			1: rect.color = Color.WHITE
			2: rect.color = Color.BLUE
		container.add_child(rect)
		rect.mouse_filter = Control.MOUSE_FILTER_PASS
		container.connect("gui_input", Callable(self, "_on_rect_clicked").bind(i))
		color_array.add_child(container)
func get_outline_style(index: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	if index == selected_index:
		style.border_color = Color.GREEN  # Green for selected
	elif selected_index != -1 and index != selected_index:
		style.border_color = Color.BLACK  # Black for swap target
	else:
		style.border_color = Color.TRANSPARENT  # No border if nothing is selected
	return style


func _on_rect_clicked(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_index == -1:
			selected_index = index  # First selection
		else:
			if selected_index != index:
				swap(selected_index, index)
			selected_index = -1  # Reset selection after swap
		update_display()

func swap(i: int, j: int):
	var temp = array[i]
	array[i] = array[j]
	array[j] = temp
	score += 1
	emit_signal("score_updated", score)

func check_solution():
	var is_correct = true
	var first_white = -1
	var first_blue = -1

	for i in range(array.size()):
		if array[i] == 1 and first_white == -1:
			first_white = i
		if array[i] == 2 and first_blue == -1:
			first_blue = i

	for i in range(array.size()):
		if (i < first_white and array[i] != 0) or (i >= first_white and i < first_blue and array[i] != 1) or (i >= first_blue and array[i] != 2):
			is_correct = false

	emit_signal("solution_checked", is_correct)
