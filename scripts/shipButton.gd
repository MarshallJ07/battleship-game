extends Node2D

@onready var grid: Sprite2D = $"../grid1"

func _ready() -> void:
	for i in get_children().size():
		get_child(i).get_child(0).pressed.connect(_pressed.bind(i))
		get_child(i).get_child(0).disabled = false
func _pressed(ship) -> void:
	grid.get_boat(Global.ships[ship])
	grid.activeShip = Global.placedShips.size()
	print(Global.placedShips)
	get_child(ship).get_child(0).disabled = true
