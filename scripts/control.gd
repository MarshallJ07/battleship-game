extends Control

@onready var host: Button = $host



func _on_host_pressed() -> void:
	Networking.host_lobby()
	host.disabled = true


func _on_start_pressed() -> void:
	if !multiplayer.is_server():
		return
	_start.rpc()
	
@rpc("any_peer","call_local","reliable")
func _start() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
