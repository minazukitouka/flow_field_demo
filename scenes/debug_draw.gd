extends Node2D

const font := preload('res://scenes/system_font.tres')


var cost_table: Dictionary:
	set(value):
		cost_table = value
		queue_redraw()
var destination_cell: Vector2i:
	set(value):
		destination_cell = value
		queue_redraw()
var integration_table: Dictionary:
	set(value):
		integration_table = value
		queue_redraw()
var flow_table: Dictionary:
	set(value):
		flow_table = value
		queue_redraw()


func _draw() -> void:
	#draw_cost_table()
	draw_grid()
	#draw_integration_table()
	draw_flow_table()


func draw_grid() -> void:
	var min_x := 255
	var max_x := 0
	var min_y := 255
	var max_y := 0
	for cell in cost_table:
		if cell.x < min_x: min_x = cell.x
		if cell.x > max_x: max_x = cell.x
		if cell.y < min_y: min_y = cell.y
		if cell.y > max_y: max_y = cell.y
	for x in range(min_x, max_x):
		draw_line(Vector2(x * 16, min_y * 16), Vector2(x * 16, max_y * 16), Color.DIM_GRAY)
	for y in range(min_y, max_y):
		draw_line(Vector2(min_x * 16, y * 16), Vector2(max_x * 16, y * 16), Color.DIM_GRAY)


func draw_cost_table() -> void:
	for cell in cost_table:
		draw_string(font, Vector2(cell * 16) + Vector2(0, 16), str(cost_table[cell]), 0, 16, 8)


func draw_integration_table() -> void:
	for cell in integration_table:
		draw_string(font, Vector2(cell * 16) + Vector2(0, 16), str(integration_table[cell]), 0, 16, 8)


func draw_flow_table() -> void:
	for cell in flow_table:
		var from := Vector2(cell * 16) + Vector2(8, 8)
		var to := Vector2(flow_table[cell] * 16) + Vector2(8, 8)
		draw_line(
			from,
			from.move_toward(to, 5),
			Color.BLUE
		)
