extends Node

signal score_updated(score: int)

var array: Array = []
var low: int = 0
var mid: int = 0
var high: int = 0
var sorting_speed: float = 1.0
var score: int = 0
var is_sorting: bool = false

@onready var color_array = $"../ColorArray"

func _ready():
	reset_array()

func reset_array():
	array = []
	score = 0
	is_sorting = false
	# Generate random array of 10 elements (0=red, 1=white, 2=blue)
	for i in range(10):
		array.append(randi() % 3)
	update_display()
	emit_signal("score_updated", score)

func update_display():
	# Clear existing elements
	for child in color_array.get_children():
		child.queue_free()
	
	# Create new color rectangles
	for i in range(array.size()):
		var rect = ColorRect.new()
		rect.size = Vector2(50, 50)
		rect.position = Vector2(i * 60 + 100, 200)
		
		match array[i]:
			0: rect.color = Color.RED
			1: rect.color = Color.WHITE
			2: rect.color = Color.BLUE
		
		color_array.add_child(rect)

func set_speed(value: float):
	sorting_speed = value

func start_sorting():
	if is_sorting:
		return
	
	is_sorting = true
	low = 0
	mid = 0
	high = array.size() - 1
	
	while mid <= high:
		if !is_sorting:
			break
			
		match array[mid]:
			0:
				swap(low, mid)
				low += 1
				mid += 1
			1:
				mid += 1
			2:
				swap(mid, high)
				high -= 1
		
		update_display()
		await get_tree().create_timer(1.0 / sorting_speed).timeout
	
	is_sorting = false
	check_solution()

func swap(i: int, j: int):
	var temp = array[i]
	array[i] = array[j]
	array[j] = temp
	score += 1
	emit_signal("score_updated", score)

func check_solution():
	var is_correct = true
	for i in range(array.size()):
		if i < low and array[i] != 0:
			is_correct = false
		elif i >= low and i < mid and array[i] != 1:
			is_correct = false
		elif i >= mid and array[i] != 2:
			is_correct = false
	
	if is_correct:
		print("Correctly sorted!")
