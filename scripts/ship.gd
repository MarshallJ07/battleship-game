extends Node2D

@onready var ship: TextureButton = $ship
@onready var ghost: Sprite2D = $ghost
func _ready() -> void:
	get_parent().get_parent().placing = true
	ship.pressed.connect(_pressed)
	
func _pressed() -> void:
	pass
