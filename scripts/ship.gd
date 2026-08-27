extends Node2D
var id = 0
var type = 0
var health: int
@onready var ship: TextureButton = $ship
@onready var ghost: Sprite2D = $ghost
func _ready() -> void:
	get_parent().get_parent().placing = true
	ship.pressed.connect(_pressed)
	health = Global.startHealths[str(type)]
	print(health)
func _pressed() -> void:
	get_parent().get_parent().selectedShip = id
