extends Sprite2D

var grid = [
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0]
]
var CELL_SIZE:int = 16
var turn = 1
var ship: Node2D
var shipSize = Vector2(4,1)
var placing := false
var placable := false
var activeShip := 0
var shipsPlaced := 0
var isReady := false
var isEnemyReady := false
var testMode := false
var selectedShip := 0
var shooting := false
@onready var fire: Button = $"../fire"
@onready var start: Button = $"../start"
@onready var ships: Node2D = $ships
@onready var readyLabel: Label = $"../ready"
@onready var enemyReadyLabel: Label = $"../enemyReady"
@onready var move: Button = $"../move"
@onready var ability: Button = $"../ability"
@onready var buttons: Node2D = $"../buttons"
@onready var ship_name: Label = $"../shipName"

var white = Sprite2D.new()

func _ready() -> void:
	add_child(ship)
	
	white.texture = preload("res://assets/art/white.png")
	white.modulate = Color(1,1,1,0.2)
	add_child(white)
func _physics_process(delta: float) -> void:
	
	
	var pos = pos_to_grid(get_local_mouse_position())
	if pos[0] >= 0 and pos[0] <= 9 and pos[1] >= 0 and pos[1] <= 9:
		white.show()
		white.position = (pos - Vector2(4.5,4.5)) * 16
	else:
		white.hide()
		
	if placing:
		check_valid_ship(shipSize,pos_to_grid(get_local_mouse_position()))
	if multiplayer.is_server():
		_check_ready.rpc()
		if isEnemyReady and isReady:
			_start_game()
		elif testMode and isReady:
			_start_game()
			
	if selectedShip != 0:
		move.show()
		ability.show()
		move.disabled = false
		ability.disabled = false
		ship_name.show()
		ship_name.text = "Ship " + str(selectedShip)
			
	
			
@rpc("any_peer","reliable")
func _check_ready() -> void:
	_enemy_ready.rpc_id(1,isReady)

@rpc("any_peer","reliable")
func _enemy_ready(enemyReady) -> void:
	isEnemyReady = enemyReady



func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("rotate"):
		if placing:
			rotate_ship()
	if Input.is_action_just_pressed("click"):
		if placing:
			if placable:
				place_ship()
	if Input.is_action_just_pressed("ui_accept"):
		print('1')
		for i in grid:
			print(i)
		print()
		print()
		print_enemy_grid.rpc() 

@rpc("any_peer","reliable")
func print_enemy_grid() -> void:
	print('2')
	for i in grid:
		print(i)
	print()
	print()

func get_boat(num:int) -> void:
	if not placing:
		
		if num == 1:
			shipSize = Vector2(1,-2)
			ship = preload("res://scenes/ship2x1.tscn").instantiate()
			ship.type = num
			Global.placedShips.append(ship)
			ship.id = Global.placedShips.size()
		elif num == 2:
			shipSize = Vector2(1,-3)
			ship = preload("res://scenes/ship3x1.tscn").instantiate()
			ship.type = num
			Global.placedShips.append(ship)
			ship.id = Global.placedShips.size()
		elif num == 3:
			shipSize = Vector2(1,-4)
			ship = preload("res://scenes/ship.tscn").instantiate()
			ship.type = num
			Global.placedShips.append(ship)
			ship.id = Global.placedShips.size()
		elif num == 4:
			shipSize = Vector2(2,-4)
			ship = preload("res://scenes/ship4x2.tscn").instantiate()
			ship.type = num
			Global.placedShips.append(ship)
			ship.id = Global.placedShips.size()
		
		ships.add_child(ship)
		
		
func place_ship() -> void:
	
	var coords = pos_to_grid(get_local_mouse_position())
	for n in abs(shipSize[0]):
		for i in abs(shipSize[1]):
			var x =  n * shipSize[0]/abs(shipSize[0])
			var y = i * shipSize[1]/abs(shipSize[1])
			print("active ship ",activeShip)
			grid[coords[1] + y][coords[0] + x] = activeShip
	ship.ship.position = Vector2(ship.ghost.position.x - CELL_SIZE/2,ship.ghost.position.y - CELL_SIZE/2)
	placing = false
	shipsPlaced += 1
func check_valid_ship(size,coord) -> void:
	var valid := true
	for n in abs(size[0]):
		for i in abs(size[1]):
			var x =  n * shipSize[0]/abs(shipSize[0])
			var y = i * shipSize[1]/abs(shipSize[1])
			if coord[0] + x > 9 or coord[0] + x < 0 or coord[1] > 9 or coord[1] < 0:
				valid = false
			if coord[1] + y > 9 or coord[1] + y < 0 or coord[0] > 9 or coord[0] < 0:
				valid = false
	if coord[0] >= 0 and coord[0] <= 9 and coord[1] >= 0 and coord[1] <= 9:
		for n in abs(shipSize[0]):
			for i in abs(shipSize[1]):
				var x =  n * shipSize[0]/abs(shipSize[0])
				var y = i * shipSize[1]/abs(shipSize[1])
				if (coord[0] + x >= 0 and coord[0] + x <= 9 and coord[1] + y >= 0 and coord[1] + y <= 9) and grid[coord[1] + y][coord[0] + x] != 0:
					valid = false
	if valid:
		placable = true
		ship.ghost.show()
		ship.ghost.position = Vector2((coord[0]-4)*16-CELL_SIZE/2,(coord[1]-4)*16-CELL_SIZE/2)
	else:
		placable = false
		ship.ghost.hide()
	ship.ship.position = Vector2(get_local_mouse_position().x - CELL_SIZE/2,get_local_mouse_position().y - CELL_SIZE/2)
		
func pos_to_grid(pos:Vector2) -> Vector2:
	return Vector2(floor((pos[0])/16)+5,floor((pos[1])/16)+5)
	
func rotate_ship() -> void:
	ship.ghost.rotation += PI/2
	ship.ship.rotation += PI/2
	var temp = Vector2(-shipSize[1],shipSize[0])
	shipSize = temp
	var coord = pos_to_grid(get_local_mouse_position())

func _start_game() -> void:
	undisable_ships.rpc()
	
@rpc("any_peer","reliable","call_local")
func undisable_ships() -> void:
	buttons.hide()
	for i in ships.get_children():
		i.ship.disabled = false

func _on_start_pressed() -> void:
	if shipsPlaced == 5:
		start.hide()
		isReady = true
		
		readyLabel.text = "READY"
		_change_ready_label.rpc()
@rpc("any_peer","reliable")
func _change_ready_label() -> void:
	enemyReadyLabel.text = "READY"


func _on_ability_pressed() -> void:
	if (turn == 1 and multiplayer.is_server()) or (turn == -1 and !multiplayer.is_server()):
		shooting = true
