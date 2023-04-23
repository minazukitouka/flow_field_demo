extends Node2D

const NEIGHBORS := [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1)
]

@onready var tile_map: TileMap = $TileMap
@onready var debug_draw: Node2D = $DebugDraw

var cost_table: Dictionary
var integration_table: Dictionary
var destination: Vector2
var flow_table: Dictionary


func _ready() -> void:
	generate_cost_table()
	debug_draw.cost_table = cost_table


func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		destination = get_global_mouse_position()
		generate_integration_table()
		generate_flow_table()


func generate_cost_table() -> void:
	for cell in tile_map.get_used_cells(0):
		if tile_map.get_cell_atlas_coords(1, cell) == Vector2i(-1, -1):
			cost_table[cell] = 1
		else:
			cost_table[cell] = 255


func generate_integration_table() -> void:
	integration_table = {}
	var destination_cell := Vector2i(destination / 16)
	integration_table[destination_cell] = 1

	var visiting_cells := [destination_cell]

	while visiting_cells.size() > 0:
		var cell: Vector2i = visiting_cells.pop_front()
		for neighbor in NEIGHBORS:
			var neighbor_cell = cell + neighbor
			if is_out_of_map(neighbor_cell):
				continue
			if integration_table.has(neighbor_cell):
				continue
			if cost_table[neighbor_cell] == 255:
				continue
			integration_table[neighbor_cell] = integration_table[cell] + cost_table[neighbor_cell]
			visiting_cells.push_back(neighbor_cell)

	debug_draw.destination_cell = destination_cell
	debug_draw.integration_table = integration_table


func generate_flow_table() -> void:
	flow_table = {}
	var destination_cell := Vector2i(destination / 16)
	for cell in integration_table:
		if cell == destination_cell:
			continue
		if is_any_neighbor_wall(cell):
			flow_table[cell] = get_flow_by_minimum_distance(cell)
		else:
			flow_table[cell] = get_flow_by_convolution_kernel_gradient(cell)
	debug_draw.flow_table = flow_table


func is_any_neighbor_wall(cell: Vector2i) -> bool:
	for neighbor in NEIGHBORS:
		var neighbor_cell = cell + neighbor
		if !integration_table.has(neighbor_cell):
			return true
	return false


func get_flow_by_minimum_distance(cell: Vector2i) -> Vector2:
	var direction := Vector2i.ZERO
	var minimum_distance := 255
	for neighbor in NEIGHBORS:
		var neighbor_cell = cell + neighbor
		if !integration_table.has(neighbor_cell):
			continue
		if integration_table[neighbor_cell] < minimum_distance:
			direction = neighbor
			minimum_distance = integration_table[neighbor_cell]
	return Vector2(direction).normalized()


func get_flow_by_convolution_kernel_gradient(cell: Vector2i) -> Vector2:
	var flow := Vector2.ZERO
	for neighbor in NEIGHBORS:
		var neighbor_cell = cell + neighbor
		flow += Vector2(neighbor) / integration_table[neighbor_cell]
	return flow.normalized()


func is_out_of_map(cell: Vector2i) -> bool:
	return !cost_table.has(cell)
