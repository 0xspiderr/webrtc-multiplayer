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

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var users: Dictionary = {}


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
		"id": id
	}
	var packet := JSON.stringify(users[id]).to_utf8_buffer()
	peer.get_peer(id).put_packet(packet)


func _on_peer_disconnected(id: int) -> void:
	pass
