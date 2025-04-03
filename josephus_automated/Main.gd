# Main.gd
extends Node2D

var circle_radius = 200
var person_radius = 20
var people = []
var n = 13  # Default number of people
var k = 2   # Skip count
var current_index = 0
var eliminated = []
var timer = 0
var step_delay = 1.0
var is_running = true
var input_field: LineEdit

class Person:
	var position: Vector2
	var eliminated: bool
	var number: int
	
	func _init(pos: Vector2, num: int):
		position = pos
		eliminated = false
		number = num

func _ready():
	# Create label for input field
	var label = Label.new()
	label.text = "Number of People:"
	label.position = Vector2(20, 80)
	label.custom_minimum_size = Vector2(120, 30)  # Fixed width for label
	add_child(label)
	
	# Create input field with more space
	input_field = LineEdit.new()
	input_field.position = Vector2(160, 80)  # Increased X position
	input_field.custom_minimum_size = Vector2(80, 30)  # Wider input field
	input_field.text = str(n)
	input_field.placeholder_text = "Enter number"
	add_child(input_field)
	
	# Create reset button with more space
	var button = Button.new()
	button.text = "Reset"
	button.position = Vector2(280, 80)  # Increased X position
	button.custom_minimum_size = Vector2(100, 30)
	add_child(button)
	button.pressed.connect(_on_reset_pressed)
	
	create_people()

func create_people():
	# Get number from input field
	var input_number = input_field.text.to_int()
	if input_number > 0:
		n = input_number
	
	people.clear()
	eliminated.clear()
	current_index = 0
	is_running = true
	
	var viewport_size = get_viewport_rect().size
	var center = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	var angle_step = 2 * PI / n
	
	for i in range(n):
		var angle = i * angle_step - PI/2
		var pos = center + Vector2(cos(angle) * circle_radius, sin(angle) * circle_radius)
		people.append(Person.new(pos, i + 1))

func _process(delta):
	if is_running:
		timer += delta
		if timer >= step_delay and people.size() - eliminated.size() > 1:
			timer = 0
			eliminate_next_person()
	
	queue_redraw()

func eliminate_next_person():
	var count = 0
	while count < k:
		if not people[current_index].eliminated:
			count += 1
		
		if count == k:
			people[current_index].eliminated = true
			eliminated.append(people[current_index])
			break
			
		current_index = (current_index + 1) % n
	
	if people.size() - eliminated.size() == 1:
		is_running = false

func _draw():
	var center = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2)
	
	# Draw circle
	draw_arc(center, circle_radius, 0, 2 * PI, 64, Color.DARK_GRAY, 2.0)
	
	# Draw people
	for person in people:
		var color = Color.GREEN if not person.eliminated else Color.RED
		draw_circle(person.position, person_radius, color)
		
		# Draw number - improved centering
		var font_color = Color.BLACK
		var number_text = str(person.number)
		
		# Get font metrics
		var font_size = 16
		var text_size = ThemeDB.fallback_font.get_string_size(number_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		
		# Calculate center position of the circle
		var text_pos = Vector2(
			person.position.x - text_size.x / 2,
			person.position.y - text_size.y / 2
		)
		
		draw_string(ThemeDB.fallback_font, text_pos, number_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, font_color)
	
	# Draw info text
	var info_text = "People: %d, k: %d, Remaining: %d" % [n, k, people.size() - eliminated.size()]
	draw_string(ThemeDB.fallback_font, Vector2(20, 30), info_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	
	if people.size() - eliminated.size() == 1:
		for person in people:
			if not person.eliminated:
				var winner_text = "Winner: Person %d" % person.number
				draw_string(ThemeDB.fallback_font, Vector2(20, 60), winner_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.GREEN)
				break

func _on_reset_pressed():
	create_people()
