extends Node2D

var width = 100

func init(size):
	width = 40 + (size * 30)
	queue_redraw()

func _draw():
	draw_rect(Rect2(-width/2, -15, width, 30), Color(0.2, 0.6, 1.0))

func get_width():
	return width
