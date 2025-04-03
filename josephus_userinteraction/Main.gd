extends Node2D

var circle_radius = 200
var person_radius = 20
var people = []
var n = 0  # No default value
var k = 2  # Skip count
var current_index = 0
var eliminated = []
var is_running = false
var input_field: LineEdit
var name_field: LineEdit
var player_name = ""
var next_to_eliminate = null
var wrong_moves = 0
var info_label: Label

class Person:
	var position: Vector2
	var eliminated: bool
	var number: int
	var highlighted: bool
	
	func _init(pos: Vector2, num: int):
		position = pos
		eliminated = false
		number = num
		highlighted = false

func _ready():
	# UI Container
	var ui_container = VBoxContainer.new()
	ui_container.position = Vector2(20, 60)
	ui_container.custom_minimum_size = Vector2(400, 100)
	add_child(ui_container)
	
	# Player Name Input
	var name_label = Label.new()
	name_label.text = "Enter Your Name:"
	ui_container.add_child(name_label)
	
	name_field = LineEdit.new()
	name_field.placeholder_text = "Your Name"
	name_field.custom_minimum_size = Vector2(300, 30)
	name_field.text_submitted.connect(_on_name_entered)
	ui_container.add_child(name_field)
	
	# Number of People Input
	var label = Label.new()
	label.text = "Enter Number of People:"
	ui_container.add_child(label)
	
	input_field = LineEdit.new()
	input_field.placeholder_text = "Press Enter after typing"
	input_field.custom_minimum_size = Vector2(300, 30)
	input_field.text_submitted.connect(_on_value_entered)
	ui_container.add_child(input_field)
	
	# Reset Button
	var reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.custom_minimum_size = Vector2(100, 30)
	reset_button.pressed.connect(_on_reset_pressed)
	ui_container.add_child(reset_button)
	
	# Info Label
	info_label = Label.new()
	info_label.text = ""
	ui_container.add_child(info_label)
	
	set_process_input(true)

func _on_name_entered(text: String):
	if text.strip_edges() == "":
		print("⚠️ Name cannot be empty!")
		return
	player_name = text.strip_edges()
	print("✅ Player Name Set:", player_name)
	
	# Move cursor to the number input field automatically
	input_field.grab_focus()

func _on_value_entered(text: String):
	if player_name == "":
		print("⚠️ Enter player name first!")
		return
	var value = text.to_int()
	if value < 2:
		print("⚠️ Minimum 2 people required!")
		return
	
	n = value
	create_people()

func create_people():
	print("✅ Creating game with n =", n)
	people.clear()
	eliminated.clear()
	current_index = 0
	is_running = true
	wrong_moves = 0
	info_label.text = ""  # Clear previous stats
	
	var viewport_size = get_viewport_rect().size
	var center = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	var angle_step = 2 * PI / n
	
	for i in range(n):
		var angle = i * angle_step - PI/2
		var pos = center + Vector2(cos(angle) * circle_radius, sin(angle) * circle_radius)
		people.append(Person.new(pos, i + 1))
	
	next_to_eliminate = null
	find_next_to_eliminate()
	queue_redraw()

func find_next_to_eliminate():
	if not is_running or people.size() == 0:
		return
	
	if next_to_eliminate:
		next_to_eliminate.highlighted = false  # Remove highlight
	
	var count = 0
	next_to_eliminate = null
	var temp_index = current_index
	
	while count < k:
		if not people[temp_index].eliminated:
			count += 1
			if count == k:
				next_to_eliminate = people[temp_index]
				break
		temp_index = (temp_index + 1) % n

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			handle_click(event.position)

func handle_click(click_pos: Vector2):
	if not is_running:
		return
		
	for person in people:
		if not person.eliminated and person.position.distance_to(click_pos) < person_radius:
			if person == next_to_eliminate:
				person.eliminated = true
				eliminated.append(person)
				person.highlighted = false
				current_index = (people.find(person) + 1) % n
				
				if people.size() - eliminated.size() == 1:
					is_running = false
					log_game_data()
				else:
					find_next_to_eliminate()
			else:
				wrong_moves += 1
			queue_redraw()
			break

func _draw():
	if people.size() == 0:
		return
		
	var center = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	
	# Draw circle
	draw_arc(center, circle_radius, 0, 2 * PI, 64, Color.DARK_GRAY, 2.0)
	
	# Draw people
	for person in people:
		var color = Color.GREEN
		if person.eliminated:
			color = Color.RED
		elif person.highlighted:
			color = Color.YELLOW
			
		draw_circle(person.position, person_radius, color)
		
		# Draw number
		var font_color = Color.BLACK
		var number_text = str(person.number)
		var font_size = 16
		var text_size = ThemeDB.fallback_font.get_string_size(number_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos = Vector2(
			person.position.x - text_size.x / 2,
			person.position.y - text_size.y / 2
		)
		draw_string(ThemeDB.fallback_font, text_pos, number_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, font_color)
	
	# Draw info text
	var info_text = "People: %d, k: %d, Remaining: %d, Wrong Moves: %d" % [n, k, people.size() - eliminated.size(), wrong_moves]
	draw_string(ThemeDB.fallback_font, Vector2(20, 30), info_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	
	if people.size() - eliminated.size() == 1:
		for person in people:
			if not person.eliminated:
				var winner_text = "🏆 Winner: Person %d" % person.number
				draw_string(ThemeDB.fallback_font, Vector2(20, 60), winner_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.GREEN)
				break

func _on_reset_pressed():
	info_label.text = ""  # Clear previous stats
	n = 0
	player_name = ""
	input_field.text = ""  # Clear text field
	name_field.text = ""   # Clear name field
	input_field.release_focus()  # Remove focus
	name_field.release_focus()
	is_running = false
	people.clear()
	eliminated.clear()
	queue_redraw()

func log_game_data():
	var file_path = "E:/Review2 godot projects_AshwinRavi/Dataset/Josephus_2.csv"

	# Check if the file exists
	if not FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.WRITE)  # Create new file
		if file == null:
			print("❌ Error: Unable to create file. Code:", FileAccess.get_open_error())
			return
		file.store_line("Timestamp,Player Name,Total People,Wrong Moves")  # Write header
		file.close()
		print("✅ File created:", file_path)

	# Now append data
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file == null:
		print("❌ Error: Unable to open file. Code:", FileAccess.get_open_error())
		return
	
	file.seek_end()  # Move to end of file
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "%s,%s,%d,%d" % [timestamp, player_name, n, wrong_moves]
	file.store_line(log_entry)
	file.close()
	
	print("✅ Data logged:", log_entry)
