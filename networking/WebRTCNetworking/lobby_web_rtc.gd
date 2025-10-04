class_name LobbyWebRTC
extends RefCounted


var host_id: int = 0
var players: Dictionary = {}


func _init(id: int) -> void:
	host_id = id


func add_player(id: int, name: String = "") -> Dictionary:
	players[id] = {
		"name": name,
		"id": id,
		"index": players.size() + 1
	}
	
	return players
