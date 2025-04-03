extends Node2D

var board_size = 0  
var cell_size = 64  
var queens = []  
var is_setup_complete = false  
var move_count = 0  
var player_name = ""  
var file_path = "E:/Review2 godot projects_AshwinRavi/Dataset/NQueens_2.csv"

# UI Elements
@onready var name_field = $UI/name_field
@onready var size_field = $UI/size_field  # Now a LineEdit for manual input
@onready var reset_button = $UI/reset_button
@onready var check_button = $UI/check_button
@onready var status_label = $UI/status_label
@onready var move_label = $UI/move_label

func _ready():
	ensure_csv_header()  # ✅ Ensure CSV file exists  
	await get_tree().process_frame  # Allow UI to load  
	connect_ui()
	name_field.grab_focus()  # Start with name input

func connect_ui():
	name_field.text_submitted.connect(_on_name_entered)
	size_field.text_submitted.connect(_on_size_entered)  # ✅ Accepts user input on Enter
	reset_button.pressed.connect(reset_board)
	check_button.pressed.connect(check_validity)

# ✅ Handle Player Name Entry
func _on_name_entered(text: String):
	text = text.strip_edges()
	if text == "":
		status_label.text = "⚠ Name cannot be empty!"
		name_field.grab_focus()
		return
	
	player_name = text
	status_label.text = "✅ Player Name Set: " + player_name
	size_field.grab_focus()  # Move focus to board size input

# ✅ Handle Board Size Entry (Loads game only when Enter is pressed)
func _on_size_entered(text: String):
	if player_name == "":
		status_label.text = "⚠ Enter your name first!"
		name_field.grab_focus()
		return
	
	var entered_size = text.strip_edges().to_int()
	if entered_size <= 0:
		status_label.text = "⚠ Enter a valid board size!"
		size_field.clear()
		size_field.grab_focus()
		return
	
	board_size = entered_size
	is_setup_complete = true  # ✅ Allow interactions
	status_label.text = "✅ Board Size Set: %d x %d" % [board_size, board_size]
	reset_board()

# ✅ Reset the Board (Clears previous stats)
func reset_board():
	queens.clear()
	move_count = 0  
	is_setup_complete = board_size > 0  # ✅ Prevent clicks until valid size is set
	update_move_label()
	status_label.text = "Board Reset. Enter Board Size to Start."
	size_field.clear()  # Clears the number field
	size_field.grab_focus()  # Focus back to input
	queue_redraw()

# ✅ Mouse Click to Place or Remove Queens
func _input(event):
	if event is InputEventMouseButton and event.pressed and is_setup_complete:
		var mouse_pos = get_local_mouse_position()
		var board_x = int(mouse_pos.x / cell_size)
		var board_y = int(mouse_pos.y / cell_size)

		if board_x < 0 or board_y < 0 or board_x >= board_size or board_y >= board_size:
			return

		var queen_pos = Vector2(board_x, board_y)

		if queen_pos in queens:
			queens.erase(queen_pos)  # Remove Queen
			move_count += 1  
		elif queens.size() < board_size:  
			queens.append(queen_pos)  # Add Queen
			move_count += 1  

		update_move_label()
		queue_redraw()

# ✅ Check if Queen Placement is Correct
func check_validity():
	if queens.size() != board_size:
		status_label.text = "⚠ Place exactly %d queens!" % board_size
		save_to_csv("⚠ Incomplete placement")
		return

	if is_valid_placement():
		status_label.text = "✔ Correct placement!"
		save_to_csv("Correct placement")
	else:
		status_label.text = "❌ Invalid placement! Try again."
		save_to_csv("Invalid placement")

# ✅ Validate Queen Positions (No Attacks)
func is_valid_placement():
	for i in range(queens.size()):
		for j in range(i + 1, queens.size()):
			var q1 = queens[i]
			var q2 = queens[j]

			if q1.x == q2.x or q1.y == q2.y or abs(q1.x - q2.x) == abs(q1.y - q2.y):
				return false
	return true

# ✅ Draw the Chessboard and Queens
func _draw():
	if not is_setup_complete:
		return
	
	for i in range(board_size):
		for j in range(board_size):
			var color = Color.WHITE if (i + j) % 2 == 0 else Color.GRAY
			var rect = Rect2(i * cell_size, j * cell_size, cell_size, cell_size)
			draw_rect(rect, color)

	for queen in queens:
		if queen.x < board_size and queen.y < board_size:  
			var pos = Vector2(queen.x * cell_size + cell_size / 2, queen.y * cell_size + cell_size / 2)
			draw_circle(pos, cell_size / 3, Color.RED)

# ✅ Update Move Counter
func update_move_label():
	if move_label:  
		move_label.text = "Moves: %d" % move_count

# ✅ Ensure CSV Exists with Header
func ensure_csv_header():
	if not FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file == null:
			print("❌ Error: Unable to create file. Code:", FileAccess.get_open_error())
			return
		file.store_line("Timestamp,Player Name,Board Size,Moves Taken,Result")
		file.close()
		print("✅ File Created:", file_path)

# ✅ Save Game Data to CSV
func save_to_csv(result):
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	file.seek_end()  # Move to end of file (append mode)
	var timestamp = Time.get_datetime_string_from_system()  
	var data = "%s,%s,%d,%d,%s" % [timestamp, player_name, board_size, move_count, result]
	file.store_line(data)
	file.close()
