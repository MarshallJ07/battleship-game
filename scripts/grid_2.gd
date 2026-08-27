extends Sprite2D


@onready var grid: Sprite2D = $"../grid1"
		
		
func pos_to_grid(pos:Vector2) -> Vector2:
	return Vector2(floor((pos[0])/16)+5,floor((pos[1])/16)+5)
	
func _input(event: InputEvent) -> void:
	if grid.shooting and Input.is_action_just_pressed("click"):
		var pos = pos_to_grid(get_local_mouse_position())
		if pos[0] >= 0 and pos[0] <= 9 and pos[1] >= 0 and pos[1] <= 9:
			_check_enemy_grid.rpc(pos)
		
@rpc("any_peer","reliable")
func _check_enemy_grid(pos) -> void:
	
	_send_shot_info.rpc(get_ship_by_id(grid.grid[pos[1]][pos[0]]))

@rpc("any_peer","reliable")
func _send_shot_info(ship) -> void:
	
	if ship.id == 0:
		print('miss')
		_miss.rpc()
	else:
		print('hit ' + str(ship.type))
		_hit.rpc(ship)
	switch_turn.rpc()
	grid.shooting = false
	
@rpc("any_peer","reliable","call_local")
func switch_turn() -> void:
	grid.turn *= -1
@rpc("any_peer","reliable")
func _hit(ship) -> void:
	ship.health -= 1
	if ship.health == 0:
		print('ship sunk')
	
@rpc("any_peer","reliable")
func _miss() -> void:
	pass
	
func get_ship_by_id(id) -> Node2D:
	for i in grid.ships.get_children():
		if i.id == id:
			return i
	return null
