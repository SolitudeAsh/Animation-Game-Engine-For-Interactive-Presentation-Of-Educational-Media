extends Node2D

var disk_scene = preload("res://disk.tscn")
var num_disks = 5
var move_speed = 1.0
var tower_spacing = 300
var disk_height = 30
var solving = false
var moves = []
var current_move = 0
var move_timer = 0.0
var move_label: Label
var disk_input: SpinBox  # New UI element to enter the number of disks

var viewport_width = 1152
var viewport_height = 648

var tower_positions = [
	viewport_width/2 - 300,  
	viewport_width/2,        
	viewport_width/2 + 300  
]

var disks = []

func _ready():
	setup_ui()
	setup_towers()
	create_disks()
	update_move_counter()

func setup_ui():
	var ui_container = HBoxContainer.new()
	ui_container.position = Vector2(10, 10)
	ui_container.size = Vector2(viewport_width - 20, 50)
	add_child(ui_container)
	
	# SpinBox for selecting number of disks
	disk_input = SpinBox.new()
	disk_input.min_value = 1
	disk_input.max_value = 10
	disk_input.value = num_disks
	disk_input.step = 1
	disk_input.custom_minimum_size = Vector2(60, 40)
	ui_container.add_child(disk_input)
	
	# Solve Button
	var solve_button = Button.new()
	solve_button.text = "Solve"
	solve_button.custom_minimum_size = Vector2(100, 40)
	solve_button.pressed.connect(solve)
	ui_container.add_child(solve_button)

	# Reset Button
	var reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.custom_minimum_size = Vector2(100, 40)
	reset_button.pressed.connect(reset_puzzle)
	ui_container.add_child(reset_button)
	
	# Speed Label
	var speed_label = Label.new()
	speed_label.text = "Speed:"
	speed_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_container.add_child(speed_label)
	
	# Speed Slider
	var slider = HSlider.new()
	slider.custom_minimum_size = Vector2(200, 20)
	slider.min_value = 0.2
	slider.max_value = 3.0
	slider.value = 1.0
	slider.step = 0.1
	slider.value_changed.connect(on_speed_changed)
	ui_container.add_child(slider)
	
	# Move Counter Label
	move_label = Label.new()
	move_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_container.add_child(move_label)

func update_move_counter():
	if moves.size() > 0:
		move_label.text = "Moves: %d / %d" % [current_move, moves.size()]
	else:
		move_label.text = "Moves: 0 / 0"

func on_speed_changed(value):
	move_speed = value

func reset_puzzle():
	solving = false
	moves = []
	current_move = 0
	move_timer = 0.0
	
	for disk in disks:
		disk.queue_free()
	disks.clear()
	
	num_disks = int(disk_input.value)  # Update num_disks from user input
	create_disks()
	update_move_counter()

func setup_towers():
	for i in range(3):
		var tower = ColorRect.new()
		tower.color = Color(0.5, 0.3, 0.1)
		tower.size = Vector2(20, 300)
		tower.position = Vector2(tower_positions[i] - 10, 150)
		add_child(tower)
		
		# Base
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

func _process(delta):
	if solving and moves.size() > 0 and current_move < moves.size():
		move_timer += delta
		if move_timer >= 1.0 / move_speed:
			move_timer = 0.0
			execute_move(moves[current_move])
			current_move += 1
			update_move_counter()

func solve():
	if not solving:
		solving = true
		moves = []
		num_disks = int(disk_input.value)  # Ensure latest value is used
		hanoi(num_disks, 0, 2, 1)
		current_move = 0
		update_move_counter()

func hanoi(n, from_tower, to_tower, aux_tower):
	if n == 1:
		moves.append([from_tower, to_tower])
		return
	hanoi(n - 1, from_tower, aux_tower, to_tower)
	moves.append([from_tower, to_tower])
	hanoi(n - 1, aux_tower, to_tower, from_tower)

func execute_move(move):
	var from_tower = move[0]
	var to_tower = move[1]
	
	var disk_to_move = null
	var highest_y = 1000
	for disk in disks:
		if abs(disk.position.x - tower_positions[from_tower]) < 10 and disk.position.y < highest_y:
			highest_y = disk.position.y
			disk_to_move = disk
	
	if disk_to_move:
		var dest_height = 420
		for disk in disks:
			if abs(disk.position.x - tower_positions[to_tower]) < 10:
				dest_height = min(dest_height, disk.position.y - disk_height)
		
		disk_to_move.position = Vector2(tower_positions[to_tower], dest_height)
