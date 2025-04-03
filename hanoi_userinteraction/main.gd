extends Node2D

var disk_scene = preload("res://disk.tscn")
var num_disks = 3  
var disk_height = 30
var selected_disk = null
var moves_made = 0
var minimum_moves = 0
var game_started = false
var player_name = ""
var csv_path = "E:/Review2 godot projects_AshwinRavi/Dataset/Hanoi_2.csv"

var viewport_width = 1152
var viewport_height = 648
var tower_positions = [
	viewport_width/2 - 300,
	viewport_width/2,
	viewport_width/2 + 300
]

var disks = []
var remark_label  # Label to display remarks after checking the solution

func _ready():
	# Create CSV file if not exists
	if not FileAccess.file_exists(csv_path):
		var file = FileAccess.open(csv_path, FileAccess.READ_WRITE)
		if file:
			file.store_line("Timestamp,Player,Disks,Moves Taken,Minimum Moves,Solution Status")
			file.close()
	
	show_name_dialog()

func show_name_dialog():
	var dialog = Window.new()
	dialog.title = "Enter Your Name"
	dialog.size = Vector2(300, 100)
	add_child(dialog)

	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)

	var label = Label.new()
	label.text = "Enter your name to start:"
	vbox.add_child(label)

	var name_input = LineEdit.new()
	vbox.add_child(name_input)

	name_input.text_submitted.connect(func(text):
		if text.strip_edges() == "":
			label.text = "⚠️ Name cannot be empty!"
			label.modulate = Color.RED
			return
		
		player_name = text.strip_edges()
		dialog.queue_free()
		show_disk_input_dialog()
	)
	
	dialog.popup_centered()

func show_disk_input_dialog():
	var dialog = Window.new()
	dialog.title = "Number of Disks"
	dialog.size = Vector2(300, 100)
	add_child(dialog)

	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)

	var label = Label.new()
	label.text = "Enter number of disks (2-8):"
	vbox.add_child(label)

	var disk_input = LineEdit.new()
	vbox.add_child(disk_input)

	disk_input.text_submitted.connect(func(text):
		var value = text.to_int()
		if value < 2 or value > 8:
			label.text = "⚠️ Enter a number between 2 and 8!"
			label.modulate = Color.RED
			return
		
		start_game(value)
		dialog.queue_free()
	)
	
	dialog.popup_centered()

func start_game(disk_count):
	num_disks = disk_count
	minimum_moves = pow(2, num_disks) - 1
	game_started = true
	moves_made = 0
	setup_ui()
	setup_towers()
	create_disks()
	update_move_counter()

func setup_ui():
	var ui_container = HBoxContainer.new()
	ui_container.position = Vector2(10, 10)
	ui_container.size = Vector2(viewport_width - 20, 50)
	add_child(ui_container)

	var moves_label = Label.new()
	moves_label.name = "MovesLabel"
	moves_label.text = "Moves: 0 / " + str(minimum_moves)
	moves_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_container.add_child(moves_label)

	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(20, 0)
	ui_container.add_child(spacer1)

	var check_button = Button.new()
	check_button.text = "Check Solution"
	check_button.custom_minimum_size = Vector2(120, 40)
	check_button.pressed.connect(check_solution)
	ui_container.add_child(check_button)

	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(20, 0)
	ui_container.add_child(spacer2)

	var reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.custom_minimum_size = Vector2(100, 40)
	reset_button.pressed.connect(reset_puzzle)
	ui_container.add_child(reset_button)

	# Remark label to display solution check status
	remark_label = Label.new()
	remark_label.text = ""
	remark_label.position = Vector2(10, 70)
	remark_label.modulate = Color(1, 1, 1)
	add_child(remark_label)

func setup_towers():
	for i in range(3):
		var tower = ColorRect.new()
		tower.color = Color(0.5, 0.3, 0.1)
		tower.size = Vector2(20, 300)
		tower.position = Vector2(tower_positions[i] - 10, 150)
		add_child(tower)

		var base = ColorRect.new()
		base.color = Color(0.5, 0.3, 0.1)
		base.size = Vector2(200, 20)
		base.position = Vector2(tower_positions[i] - 90, 450)
		add_child(base)

func create_disks():
	for i in range(num_disks):
		var disk = disk_scene.instantiate()
		disk.position = Vector2(tower_positions[0], 420 - (i * disk_height))
		disk.init(num_disks - i)
		disks.append(disk)
		add_child(disk)

func _input(event):
	if not game_started:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = event.position
				if not selected_disk:
					selected_disk = try_select_disk(mouse_pos)
			else:
				if selected_disk:
					if try_place_disk(event.position):
						moves_made += 1
						update_move_counter()
					selected_disk = null

	elif event is InputEventMouseMotion and selected_disk:
		selected_disk.position.x = event.position.x
		selected_disk.position.y = event.position.y

func try_select_disk(pos):
	var closest_disk = null
	var closest_distance = 1000

	for disk in disks:
		if abs(disk.position.x - pos.x) < 50 and abs(disk.position.y - pos.y) < 20:
			var dist = abs(disk.position.y - pos.y)
			if dist < closest_distance:
				var is_top = true
				var disk_tower = get_tower_index(disk.position.x)
				for other_disk in disks:
					if other_disk != disk and get_tower_index(other_disk.position.x) == disk_tower:
						if other_disk.position.y < disk.position.y:
							is_top = false
							break

				if is_top:
					closest_distance = dist
					closest_disk = disk

	return closest_disk

func try_place_disk(pos):
	var tower_index = get_tower_index(pos.x)
	if tower_index == -1:
		return false

	if is_valid_move(selected_disk, tower_index):
		var place_height = 420
		for disk in disks:
			if disk != selected_disk and get_tower_index(disk.position.x) == tower_index:
				place_height = min(place_height, disk.position.y - disk_height)

		selected_disk.position = Vector2(tower_positions[tower_index], place_height)
		return true

	return false

func get_tower_index(x_pos):
	for i in range(3):
		if abs(tower_positions[i] - x_pos) < 100:
			return i
	return -1

func is_valid_move(disk, tower_index):
	for other_disk in disks:
		if other_disk != disk and get_tower_index(other_disk.position.x) == tower_index:
			if other_disk.get_width() < disk.get_width():
				return false
	return true

func update_move_counter():
	var label = find_child("MovesLabel", true, false)
	if label:
		label.text = "Moves: %d / %d" % [moves_made, minimum_moves]

func check_solution():
	var is_solved = true
	var prev_width = 999
	
	# Check if all disks are on the rightmost tower in order
	for disk in disks:
		if get_tower_index(disk.position.x) != 2:  # Right tower
			is_solved = false
			break
		if disk.get_width() > prev_width:
			is_solved = false
			break
		prev_width = disk.get_width()
	
	# ✅ Update remark label on screen
	remark_label.text = "[color=green]✅ Congratulations![/color] 🎉 You solved it in [b][color=yellow]%d[/color][/b] moves!" % moves_made if is_solved else "[color=red]❌ Not solved yet![/color] 😞 Keep trying!"	
	
	# ✅ Open the CSV file in **READ_WRITE mode and seek to the end**
	var file = FileAccess.open(csv_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()  # Move to the end of the file before writing

		# ✅ Add **player's name** to the CSV
		var current_time = Time.get_datetime_string_from_system()
		var line = "%s,%s,%d,%d,%d,%s" % [
			current_time,
			player_name,  # <--- **This ensures the name is recorded!**
			num_disks,
			moves_made,
			minimum_moves,
			"Solved!" if is_solved else "Keep trying"
		]
		file.store_line(line)
		file.close()



func reset_puzzle():
	for disk in disks:
		disk.queue_free()
	disks.clear()
	moves_made = 0
	selected_disk = null
	remark_label.text = ""  # Clears the remark on screen
	create_disks()
	update_move_counter()
