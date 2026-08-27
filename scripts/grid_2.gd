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
	_send_shot_info.rpc(grid.grid[pos[1]][pos[0]])

@rpc("any_peer","reliable")
func _send_shot_info(type) -> void:
	if type == 0:
		_miss()
	else:
		_hit(type)
	grid.turn *= -1
	grid.shooting = false

func _hit(type) -> void:
	print('hit ' + str(type))

func _miss() -> void:
	print('miss')
