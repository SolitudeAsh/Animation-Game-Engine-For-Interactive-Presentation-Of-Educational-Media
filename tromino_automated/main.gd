extends Node2D

var board_size = 8  # Must be a exponent of 2
var cell_size = 64
var board = []
var tromino_count = 0
var colors = [
	Color(0.9, 0.1, 0.1),  # Red
	Color(0.1, 0.9, 0.1),  # Green
	Color(0.1, 0.1, 0.9),  # Blue
	Color(0.9, 0.9, 0.1),  # Yellow
	Color(0.9, 0.1, 0.9),  # Magenta
	Color(0.1, 0.9, 0.9),  # Cyan
]

var solving = false
var solve_speed = 1.0  # Default speed multiplier
var solving_steps = []
var current_step = 0

# UI Elements
@onready var reset_button = $CanvasLayer/ResetButton
@onready var speed_slider = $CanvasLayer/SpeedSlider
@onready var speed_label = $CanvasLayer/SpeedLabel
@onready var step_timer: Timer = $CanvasLayer/StepTimer

func _ready():
	randomize()
	setup_ui()
	ensure_timer_exists()
	reset_puzzle()

func setup_ui():
	# Initialize speed slider (Left = Slow, Right = Fast)
	speed_slider.min_value = 0.5  # Slowest
	speed_slider.max_value = 20.0 # Fastest
	speed_slider.value = solve_speed
	speed_slider.connect("value_changed", _on_speed_changed)
	update_speed_label()
	
	# Initialize reset button
	reset_button.connect("pressed", reset_puzzle)

func ensure_timer_exists():
	if not step_timer:
		step_timer = Timer.new()
		step_timer.name = "StepTimer"
		step_timer.one_shot = true
		add_child(step_timer)
	step_timer.wait_time = 1.0 / solve_speed  # Adjust speed
	step_timer.connect("timeout", _process_tromino_step)

func _on_speed_changed(value):
	solve_speed = value
	update_speed_label()
	
	if step_timer:
		step_timer.wait_time = 1.0 / solve_speed
		if solving and not step_timer.is_stopped():
			step_timer.stop()
			step_timer.start()

func update_speed_label():
	speed_label.text = "Speed: %.1fx" % solve_speed

func reset_puzzle():
	board = []
	tromino_count = 0
	solving_steps = []
	current_step = 0
	solving = false
	
	initialize_board()
	
	# Place initial missing square randomly
	var missing_x = randi() % board_size
	var missing_y = randi() % board_size
	board[missing_y][missing_x] = -1
	
	# Generate solution steps
	solve_tromino(0, 0, board_size, missing_x, missing_y)
	
	# Start animation
	solving = true
	current_step = 0
	step_timer.start()
	queue_redraw()

func initialize_board():
	board = []
	for y in range(board_size):
		var row = []
		for x in range(board_size):
			row.append(0)
		board.append(row)

class TrominoStep:
	var positions = []  # Array of Vector2i for the three squares to fill
	var tromino_number: int
	
	func _init(p: Array, n: int):
		positions = p
		tromino_number = n

func solve_tromino(x: int, y: int, size: int, missing_x: int, missing_y: int):
	if size == 1:
		return
		
	tromino_count += 1
	var current_tromino = tromino_count
	var half_size = size / 2
	
	# Find which quadrant has the missing square
	var quadrant = 0
	if missing_x < x + half_size:
		if missing_y < y + half_size:
			quadrant = 0  # Top-left
		else:
			quadrant = 2  # Bottom-left
	else:
		if missing_y < y + half_size:
			quadrant = 1  # Top-right
		else:
			quadrant = 3  # Bottom-right
	
	# Place tromino in center
	var center_x = x + half_size - 1
	var center_y = y + half_size - 1
	
	# Create step for animation
	var step_positions = []
	for i in range(2):
		for j in range(2):
			if (i * 2 + j) != quadrant:
				step_positions.append(Vector2i(center_x + j, center_y + i))
	solving_steps.append(TrominoStep.new(step_positions, current_tromino))
	
	# Recursively solve for each quadrant
	var new_missing_x
	var new_missing_y
	
	# Top-left quadrant
	if quadrant == 0:
		new_missing_x = missing_x
		new_missing_y = missing_y
	else:
		new_missing_x = center_x
		new_missing_y = center_y
	solve_tromino(x, y, half_size, new_missing_x, new_missing_y)
	
	# Top-right quadrant
	if quadrant == 1:
		new_missing_x = missing_x
		new_missing_y = missing_y
	else:
		new_missing_x = center_x + 1
		new_missing_y = center_y
	solve_tromino(x + half_size, y, half_size, new_missing_x, new_missing_y)
	
	# Bottom-left quadrant
	if quadrant == 2:
		new_missing_x = missing_x
		new_missing_y = missing_y
	else:
		new_missing_x = center_x
		new_missing_y = center_y + 1
	solve_tromino(x, y + half_size, half_size, new_missing_x, new_missing_y)
	
	# Bottom-right quadrant
	if quadrant == 3:
		new_missing_x = missing_x
		new_missing_y = missing_y
	else:
		new_missing_x = center_x + 1
		new_missing_y = center_y + 1
	solve_tromino(x + half_size, y + half_size, half_size, new_missing_x, new_missing_y)

func _process(delta):
	if solving and current_step < solving_steps.size():
		if step_timer.is_stopped():
			_process_tromino_step()
			step_timer.start()

func _process_tromino_step():
	if current_step < solving_steps.size():
		var step = solving_steps[current_step]
		for pos in step.positions:
			board[pos.y][pos.x] = step.tromino_number
		current_step += 1
		queue_redraw()

func _draw():
	# Draw the board grid
	for y in range(board_size):
		for x in range(board_size):
			var rect = Rect2(x * cell_size, y * cell_size, cell_size, cell_size)
			if board[y][x] == -1:
				draw_rect(rect, Color.BLACK, true)  # Missing square
			else:
				var color_idx = (board[y][x] - 1) % colors.size() if board[y][x] > 0 else -1
				if color_idx >= 0:
					draw_rect(rect, colors[color_idx], true)
			draw_rect(rect, Color.WHITE, false)  # Grid lines
