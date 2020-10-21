extends TileMap

# Signal for informing the main scene about changed number of moves
signal moves_changed()

# Variable for all game fields that must be filled with movable blocks
var datamap = []
# Variable for empty spaces on the gamefield
var empty_cells = [Vector2(3, 5), Vector2(3, 7), Vector2(5, 5), Vector2(5, 7)]
# Variable for cell for swapping, 0,0 is the default position, because that cell cannot be swapped.
var cell_for_swap = Vector2(0, 0)


# Called when the node enters the scene tree for the first time. Initializes a new game
func _ready():
	randomize()
	Game.map = self
	set_cursor_hidden(true)
	fill_datamap()
	new_game()

# Function for starting a new game. Called at the start and when the corresponding button is pressed
func new_game():
	Game.moves = 0
	Game.won = false
	shuffle_datamap()
	draw_map()

# Function for selecting cell, that was pressed on. 
# If this cell is inside game field and not a blocker, then swapping process is inititated
func _input(mouseEvent):
	if mouseEvent is InputEventMouseButton:
		if mouseEvent.button_index == BUTTON_LEFT and mouseEvent.pressed:
			var clicked_cell = world_to_map(mouseEvent.position)
			if ((2 <= clicked_cell[0]) and (clicked_cell[0] <= 6) and 
			(4 <= clicked_cell[1]) and (clicked_cell[1] <= 8) and
			(get_cellv(clicked_cell) >= 2) and
			Game.won == false):
				swap_cells(clicked_cell)

# Function for swapping cells
func swap_cells(cell):
	# If no cells were selected for swapping before, we remember the selected now and let the player choose another one. 
	if (cell_for_swap == Vector2(0, 0)):
		cell_for_swap = cell
		return
	# If cells are neighbors and one of them is an empty space, 
	# then cells are swapped, number of moves is incremented, and cell for swap is "deselected"
	# Else selected cell is chosen as the cell for swapping
	if (check_neighborhood(cell_for_swap, cell) and 
	(get_cellv(cell_for_swap) == 2 or get_cellv(cell) == 2)):
		var new_cell_vall = get_cellv(cell_for_swap)
		set_cell(cell_for_swap.x, cell_for_swap.y, get_cellv(cell))
		set_cell(cell.x, cell.y, new_cell_vall)
		cell_for_swap = Vector2(0, 0)
		Game.moves += 1
		emit_signal('moves_changed')
	else:
		cell_for_swap = cell

# Function for checking if two cells are neighbors
func check_neighborhood(cell_a, cell_b):
	if ((cell_a.x == cell_b.x) and (abs(cell_a.y - cell_b.y) == 1) or 
	(cell_a.y == cell_b.y) and (abs(cell_a.x - cell_b.x) == 1)):
		return true
	else:
		return false

# Function for filling datamap with numbers, corresponding to tile numbers in the tileset
# 2 - Empty, 3 - Blue, 4 - Green, 5 - Red
func fill_datamap():
	for i in range(15):
		datamap.append(3 + i/5)

# Function for making the order of colors random
func shuffle_datamap():
	datamap.shuffle()

# Function for filling the gamefield with corresponding blocks
func draw_map():
	for i in range(15):
		set_cell(2 + (i/5)*2 , 4 + i%5, datamap[i])
	for i in range(4):
		set_cell(empty_cells[i].x, empty_cells[i].y, 2)

# Function for checking if the game is won, called every move. Not efficient, but readable
func check_win():
	var seems_as_a_win = true
	for i in range(15):
		if (get_cellv(Vector2(2 + (i/5)*2 , 4 + i%5)) != (3 + i/5)):
			seems_as_a_win = false
			return seems_as_a_win
	Game.won = seems_as_a_win
	return seems_as_a_win

# Function for hiding cursor
func set_cursor_hidden(is_hidden):
	get_node('Cursor').set_visible(!(is_hidden))

# Function for drawing cursor on the game field
func set_cursor():
	var cell = world_to_map(get_local_mouse_position())
	get_node('Cursor').set_position(map_to_world(cell))
