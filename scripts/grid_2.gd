extends Sprite2D


@onready var grid: Sprite2D = $"../grid1"
@onready var turn: Label = $"../turn"
var white = Sprite2D.new()

func _ready() -> void:
	white.texture = preload("res://assets/art/white.png")
	white.modulate = Color(1,1,1,0.2)

func _physics_process(delta: float) -> void:
	
	
	add_child(white)
	var pos = pos_to_grid(get_local_mouse_position())
	if pos[0] >= 0 and pos[0] <= 9 and pos[1] >= 0 and pos[1] <= 9:
		white.show()
		white.position = (pos - Vector2(4.5,4.5)) * 16
	else:
		white.hide()
func pos_to_grid(pos:Vector2) -> Vector2:
	return Vector2(floor((pos[0])/16)+5,floor((pos[1])/16)+5)
	
func _input(event: InputEvent) -> void:
	if grid.shooting and Input.is_action_just_pressed("click"):
		var pos = pos_to_grid(get_local_mouse_position())
		if pos[0] >= 0 and pos[0] <= 9 and pos[1] >= 0 and pos[1] <= 9:
			_check_enemy_grid.rpc(pos)
		
@rpc("any_peer","reliable")
func _check_enemy_grid(pos) -> void:
	
	_send_shot_info.rpc(grid.grid[pos[1]][pos[0]])

@rpc("any_peer","reliable")
func _send_shot_info(id) -> void:
	var ship = get_ship_by_id(id)
	if id == 0:
		print('miss')
		_miss.rpc()
	else:
		print('hit ' + str(ship.type), ", ship has ", str(ship.health), " health left")
		_hit.rpc(id)
		
	switch_turn.rpc()
	grid.shooting = false
	
@rpc("any_peer","reliable","call_local")
func switch_turn() -> void:
	grid.turn *= -1
	if grid.turn == 1:
		turn.text = "PLAYER 1's TURN"
	else:
		turn.text = "PLAYER 2's TURN"
@rpc("any_peer","reliable")
func _hit(id) -> void:
	var ship = get_ship_by_id(id)
	ship.health -= 1
	if ship.health == 0:
		sink_ship(id, Steam.getPersonaName())
		print('ship sunk')
	
@rpc("any_peer","reliable")
func _miss() -> void:
	pass

@rpc("any_peer","reliable","call_local")
func sink_ship(id, name) -> void:
	var ship = get_ship_by_id(id)
	ship.ship.disabled = true
	ship.modulate = Color(0.378, 0.0, 0.0, 1.0)
	var shipLeft = false
	for y in grid.grid.size():
		for x in grid.grid[y].size():
			if grid.grid[y][x] == id:
				grid.grid[y][x] = 0
			if grid.grid[y][x] != 0:
				shipLeft = true
	if !shipLeft:
		print("Game Over, ", name, " wins")
	
func get_ship_by_id(id) -> Node2D:
	for i in grid.ships.get_children():
		if i.id == id:
			return i
	return null
