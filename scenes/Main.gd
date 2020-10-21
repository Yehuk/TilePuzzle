extends Control

# Connection to scene objects from code
onready var viewport_panel = get_node('map')
onready var movesnum = get_node('InfoContainer').get_node('MovesContainer').get_node('MovesNum')
onready var status = get_node('InfoContainer').get_node('Status')

# Variables for the tracking of mouse position
var is_mouse_in_map = false setget _set_is_mouse_in_map
var mouse_cell = Vector2() setget _set_mouse_cell

# Function for showing and hiding cursor when it is on and off map respectively
func _set_is_mouse_in_map(what):
	is_mouse_in_map = what
	Game.map.set_cursor_hidden(!is_mouse_in_map)

# Function for telling map to draw a cursor
func _set_mouse_cell(what):
	mouse_cell = what
	Game.map.set_cursor()

# Function for tracking mouse movement on map
func _input(mouseEvent):
	if mouseEvent is InputEventMouseMotion:
		var mpos = mouseEvent.position
		var mrect = Rect2(mpos,Vector2(1,1))
		self.is_mouse_in_map = viewport_panel.get_rect().intersects(mrect)
		var new_mouse_cell = Game.map.world_to_map(Game.map.get_local_mouse_position())
		if new_mouse_cell != mouse_cell:
			self.mouse_cell = new_mouse_cell

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.game = self

# Function for changing label with current moves amount
func _on_Map_moves_changed():
	movesnum.set_text(str(Game.moves))
	if(Game.map.check_win()):
		status.set_text("You won! Congratulations!")

# Function for "New Game" button, which resets a game state
func _on_NewGame_pressed():
	Game.map.new_game()
	movesnum.set_text("None")
	status.set_text("Keep going!")
