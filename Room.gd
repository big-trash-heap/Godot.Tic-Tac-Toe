extends Node

enum ITEM_TYPE {
	OUTTYPE = 0,
	NONTYPE = 1,
	CROSS  = 1 << 1,
	CIRCLE = 1 << 2,
}

enum CROSS_TYPE {
	ANGLE_0    = 1 << 3,
	ANGLE_45   = 1 << 4,
	ANGLE_90   = 1 << 5,
	ANGLE_135  = 1 << 6,
}

const CHECK_DIRECTIONS = [
	{
		"angle": CROSS_TYPE.ANGLE_0,
		"positions": [Vector2(1, 0), Vector2(-1, 0)]
	},
	{
		"angle": CROSS_TYPE.ANGLE_45,
		"positions": [Vector2(1, 1), Vector2(-1, -1)]
	},
	{
		"angle": CROSS_TYPE.ANGLE_90,
		"positions": [Vector2(0, 1), Vector2(0, -1)]
	},
	{
		"angle": CROSS_TYPE.ANGLE_135,
		"positions": [Vector2(1, -1), Vector2(-1, 1)]
	},
]

var grid
var item
var game
var step
onready var s_item = load("res://Item.tscn")

func new_game():
	print("\nStart new game!")
	
	grid = [
		[ITEM_TYPE.NONTYPE, ITEM_TYPE.NONTYPE, ITEM_TYPE.NONTYPE],
		[ITEM_TYPE.NONTYPE, ITEM_TYPE.NONTYPE, ITEM_TYPE.NONTYPE],
		[ITEM_TYPE.NONTYPE, ITEM_TYPE.NONTYPE, ITEM_TYPE.NONTYPE],
	]
	
	item = ITEM_TYPE.CROSS
	game = true
	step = 9
	
	for node in $Container.get_children():
		node.queue_free()

func cell_in(pos: Vector2) -> bool:
	return (pos.x >= 0 && pos.x <= 2 && pos.y >= 0 && pos.y <= 2)

func cell_get(pos: Vector2) -> int:
	
	if cell_in(pos):
		return grid[pos.x][pos.y]
	
	return ITEM_TYPE.OUTTYPE

func cell_set(pos: Vector2, type: int) -> bool:
	
	if grid[pos.x][pos.y] != ITEM_TYPE.NONTYPE:
		return false
	
	grid[pos.x][pos.y] = type
	
	var node = s_item.instance()
	$Container.add_child(node)
	
	node.position = (pos * 200) + Vector2(100, 100)
	if type == ITEM_TYPE.CROSS:
		node.set_cross()
	else:
		node.set_circle()
	
	# Этот алгоритм проверяет закончилась ли игра победой <type>
	# Я не до конца уверен что он работает, в любом случаи цель была не в
	#	правильном алгоритме
	var check_pos
	var check_cell
	for dir in CHECK_DIRECTIONS:
		
		for vec in dir.positions:
			
			check_pos = vec + pos
			check_cell = cell_get(check_pos)
			
			if (check_cell & type) > 0:
				
				if check_cell & dir.angle > 0:
					return true
				elif grid[pos.x][pos.y] & dir.angle > 0:
					return true
				else:
					grid[pos.x][pos.y] |= dir.angle
					grid[check_pos.x][check_pos.y] |= dir.angle
	
	return false




func _ready():
	new_game()

func _input(event):
	if game:
		if event is InputEventMouseButton && event.is_doubleclick():
			var mouse = (get_viewport().get_mouse_position() / 200).floor()
			if cell_in(mouse):
				
				if cell_set(mouse, item):
					game = false
					
					if item == ITEM_TYPE.CIRCLE:
						print("Win Circle!")
					else:
						print("Win Cross!")
					
					print("Press Space to restart")
					return
				
				step -= 1
				if step == 0:
					game = false
					
					print("No winner!")
					print("Press Space to restart")
					return
				
				if item == ITEM_TYPE.CIRCLE:
					item = ITEM_TYPE.CROSS
				else:
					item = ITEM_TYPE.CIRCLE
	elif event is InputEventKey && event.scancode == ord(" "):
		new_game()
