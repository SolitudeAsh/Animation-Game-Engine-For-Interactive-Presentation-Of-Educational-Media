extends Node2D

# Constants for visualization
const BAR_WIDTH = 50
const MAX_HEIGHT = 400
const SPACE_BETWEEN = 20
var ANIMATION_SPEED = 0.5  # Now variable for slider control

# Array to sort
var numbers: Array = []
var bars: Array = []
var tween: Tween
var sorting = false
var current_index = 1

# UI Elements
var input_field: LineEdit
var speed_slider: HSlider
var status_label: Label

func _ready():
	create_ui_elements()
	
func create_ui_elements():
	# Create input field for numbers
	var input_label = Label.new()
	input_label.text = "Enter numbers (comma-separated):"
	input_label.position = Vector2(50, 620)
	add_child(input_label)
	
	input_field = LineEdit.new()
	input_field.position = Vector2(50, 650)
	input_field.size = Vector2(400, 40)
	input_field.placeholder_text = "Example: 64,34,25,12,22,11,90"
	add_child(input_field)
	
	# Create speed control slider
	var slider_label = Label.new()
	slider_label.text = "Animation Speed:"
	slider_label.position = Vector2(500, 620)
	add_child(slider_label)
	
	speed_slider = HSlider.new()
	speed_slider.position = Vector2(500, 650)
	speed_slider.size = Vector2(250, 30)
	speed_slider.min_value = 0.1
	speed_slider.max_value = 2.0
	speed_slider.value = 0.5
	speed_slider.step = 0.1
	speed_slider.value_changed.connect(_on_speed_changed)
	add_child(speed_slider)
	
	# Create status label
	status_label = Label.new()
	status_label.position = Vector2(50, 700)
	status_label.modulate = Color.RED
	add_child(status_label)
	
	# Create buttons
	var enter_button = Button.new()
	enter_button.text = "Enter Numbers"
	enter_button.position = Vector2(50, 570)
	enter_button.size = Vector2(150, 40)
	enter_button.pressed.connect(_on_enter_pressed)
	add_child(enter_button)
	
	var sort_button = Button.new()
	sort_button.text = "Sort"
	sort_button.position = Vector2(220, 570)
	sort_button.size = Vector2(120, 40)
	sort_button.pressed.connect(_on_sort_pressed)
	add_child(sort_button)
	
	var reset_button = Button.new()
	reset_button.text = "Random Numbers"
	reset_button.position = Vector2(370, 570)
	reset_button.size = Vector2(180, 40)
	reset_button.pressed.connect(_on_reset_pressed)
	add_child(reset_button)

func _on_speed_changed(value: float):
	ANIMATION_SPEED = 1.0 - (value - 0.1) / 1.9  # Invert scale for more intuitive control

func _on_enter_pressed():
	var input_text = input_field.text.strip_edges()
	if input_text.is_empty():
		status_label.text = "Please enter some numbers!"
		return
		
	var number_strings = input_text.split(",")
	numbers.clear()
	
	for num_str in number_strings:
		var num_str_trimmed = num_str.strip_edges()
		if num_str_trimmed.is_valid_int():
			var num = num_str_trimmed.to_int()
			if num > 0 and num <= 100:
				numbers.append(num)
			else:
				status_label.text = "Numbers must be between 1 and 100!"
				return
		else:
			status_label.text = "Invalid input! Please enter comma-separated numbers."
			return
	
	if numbers.size() > 15:
		status_label.text = "Please enter 15 or fewer numbers!"
		return
		
	status_label.text = ""
	sorting = false
	current_index = 1
	create_bars()

func create_bars():
	# Clear existing bars
	for bar in bars:
		bar.queue_free()
	bars.clear()
	
	# Create new bars
	for i in range(numbers.size()):
		var bar = ColorRect.new()
		bar.color = Color(1, 1, 1)  # White color
		bar.position = Vector2(100 + i * (BAR_WIDTH + SPACE_BETWEEN), 520)  # Shifted right
		bar.size = Vector2(BAR_WIDTH, -numbers[i] * 4)  # Negative height to grow upward
		
		# Add value label
		var label = Label.new()
		label.text = str(numbers[i])
		label.position = Vector2(BAR_WIDTH / 4, 10)
		bar.add_child(label)
		
		bars.append(bar)
		add_child(bar)

func insertion_sort_step():
	if current_index >= numbers.size():
		sorting = false
		status_label.text = "Sorting completed!"
		return
	
	var key = numbers[current_index]
	var j = current_index - 1
	
	while j >= 0 and numbers[j] > key:
		# Swap values in array
		numbers[j + 1] = numbers[j]
		
		# Animate the swap
		tween = create_tween()
		tween.set_parallel(true)
		
		# Move right bar to left position
		tween.tween_property(bars[j + 1], "position:x", 
			100 + j * (BAR_WIDTH + SPACE_BETWEEN), ANIMATION_SPEED)
		
		# Move left bar to right position
		tween.tween_property(bars[j], "position:x", 
			100 + (j + 1) * (BAR_WIDTH + SPACE_BETWEEN), ANIMATION_SPEED)
		
		# Swap bars in array
		var temp_bar = bars[j]
		bars[j] = bars[j + 1]
		bars[j + 1] = temp_bar
		
		j -= 1
	
	numbers[j + 1] = key
	
	# Highlight current bar being inserted
	for bar in bars:
		bar.color = Color(1, 1, 1)  # Reset to white
	bars[current_index].color = Color(0, 1, 0)  # Green for current element
	
	current_index += 1

func _process(_delta):
	if sorting and (tween == null or not tween.is_running()):
		insertion_sort_step()

func _on_sort_pressed():
	if numbers.is_empty():
		status_label.text = "Please enter numbers first!"
		return
		
	if not sorting:
		status_label.text = "Sorting in progress..."
		sorting = true
		current_index = 1

func _on_reset_pressed():
	sorting = false
	current_index = 1
	
	# Generate new random numbers
	numbers.clear()
	for i in range(10):
		numbers.append(randi() % 100 + 1)
	
	# Recreate visualization
	create_bars()
	status_label.text = ""
