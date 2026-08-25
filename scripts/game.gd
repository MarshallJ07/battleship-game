extends Node2D


func _ready():
	Networking.host_created.connect(_on_host_created)
	multiplayer.peer_connected.connect(_peer_connected)
	
func _on_host_created():
	pass
	
func _peer_connected(peer_id:int):
	pass
ssdfasdf
