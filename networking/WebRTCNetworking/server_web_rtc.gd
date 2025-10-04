class_name ServerWebRTC
extends Node

enum Message
{
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer
}

var characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var users: Dictionary = {}
var lobbies: Dictionary = {}


func _ready() -> void:
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)


func _process(_delta: float) -> void:
	peer.poll()
	
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
			print(data)
			
			if data.message == Message.lobby:
				join_lobby(int(data.id), data.lobby_value)


func join_lobby(user_id, lobby_id) -> void:
	if lobby_id == "":
		lobby_id = generate_rand_str()
		lobbies[lobby_id] = LobbyWebRTC.new(user_id)
	
	lobbies[lobby_id].add_player(user_id)
	var data = {
		"message": int(Message.userConnected),
		"id": int(user_id),
		"host": int(lobbies[lobby_id].host_id),
		"player": lobbies[lobby_id].players[user_id]
	}
	var packet = JSON.stringify(data).to_utf8_buffer()
	peer.get_peer(user_id).put_packet(packet)


func generate_rand_str():
	randomize()
	var result = ""
	for i in range(32):
		var random_index = randi() % characters.length()
		result += characters[random_index]
	
	return result

func _start_server() -> void:
	var err = peer.create_server(9999)
	
	if err:
		printerr(err)
		return
	
	print("started server")


func _on_server_btn_pressed() -> void:
	_start_server()


func _on_peer_connected(id: int) -> void:
	users[id] = {
		"id": id,
		"message": Message.id
	}
	var packet := JSON.stringify(users[id]).to_utf8_buffer()
	peer.get_peer(id).put_packet(packet)


func _on_peer_disconnected(id: int) -> void:
	pass
