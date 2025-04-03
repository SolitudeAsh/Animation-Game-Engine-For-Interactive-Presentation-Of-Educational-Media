extends Node2D

var board_size  # No default value; user must select
var cell_size = 64  # Cell size in pixels
var board = []
var queens = []
var total_solutions = 0  # Stores total number of solutions

var solve_button
var size_spinner
var solutions_label  # Label to display the solution count

func _ready():
	create_ui()

func create_ui():
	# UI elements placed dynamically to the right of the board
	var ui_x_offset = (board_size if board_size else 8) * cell_size + 20  # Default 8x8 size

	# Create a size selector (SpinBox)
	size_spinner = SpinBox.new()
	size_spinner.min_value = 4
	size_spinner.max_value = 12
	size_spinner.value = 4  # Minimum value
	size_spinner.position = Vector2(ui_x_offset, 20)
	size_spinner.connect("value_changed", _on_size_changed)
	add_child(size_spinner)

	# Create a "Solve" button
	solve_button = Button.new()
	solve_button.text = "Solve"
	solve_button.position = Vector2(ui_x_offset, 60)
	solve_button.connect("pressed", _on_solve_pressed)
	solve_button.disabled = true  # Disabled until user sets a size
	add_child(solve_button)

	# Label to display the total number of solutions
	solutions_label = Label.new()
	solutions_label.text = "Total Solutions: 0"
	solutions_label.position = Vector2(ui_x_offset, 100)
	add_child(solutions_label)

func _on_size_changed(value):
	board_size = int(value)
	solve_button.disabled = false  # Enable solving once size is set
	initialize_board()
	queue_redraw()
	update_ui_positions()  # Adjust UI elements dynamically

func update_ui_positions():
	var ui_x_offset = board_size * cell_size + 20
	size_spinner.position = Vector2(ui_x_offset, 20)
	solve_button.position = Vector2(ui_x_offset, 60)
	solutions_label.position = Vector2(ui_x_offset, 100)

func initialize_board():
	board = []
	queens = []
	total_solutions = 0  # Reset solution count
	solutions_label.text = "Total Solutions: 0"
	for i in range(board_size):
		var row = []
		for j in range(board_size):
			row.append(0)
		board.append(row)

func _draw():
	if board_size != null:
		draw_board()
		draw_queens()

func draw_board():
	for i in range(board_size):
		for j in range(board_size):
			var color = Color.WHITE if (i + j) % 2 == 0 else Color.GRAY
			var rect = Rect2(i * cell_size, j * cell_size, cell_size, cell_size)
			draw_rect(rect, color)

func draw_queens():
	for queen in queens:
		var pos = Vector2(queen.x * cell_size + cell_size / 2, queen.y * cell_size + cell_size / 2)
		draw_circle(pos, cell_size / 3, Color.RED)

func is_safe(row, col):
	for i in range(board_size):
		if board[row][i] == 1 or board[i][col] == 1:
			return false
	for i in range(board_size):
		for j in range(board_size):
			if board[i][j] == 1 and abs(row - i) == abs(col - j):
				return false
	return true

func count_solutions(col = 0):
	if col >= board_size:
		total_solutions += 1
		return

	for i in range(board_size):
		if is_safe(i, col):
			board[i][col] = 1
			count_solutions(col + 1)
			board[i][col] = 0

func solve_queens(col = 0):
	if col >= board_size:
		return true

	for i in range(board_size):
		if is_safe(i, col):
			board[i][col] = 1
			queens.append(Vector2(col, i))

			if solve_queens(col + 1):
				return true  # Stop at first valid solution

			board[i][col] = 0
			queens.pop_back()

	return false

func _on_solve_pressed():
	initialize_board()
	total_solutions = 0  # Reset count before solving
	count_solutions()  # Count all possible solutions
	solutions_label.text = "Total Solutions: " + str(total_solutions)  # Update UI
	solve_queens()  # Solve and visualize one solution
	queue_redraw()
