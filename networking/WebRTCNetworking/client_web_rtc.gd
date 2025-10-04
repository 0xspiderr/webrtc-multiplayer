class_name ClientWebRTC
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

@onready var lobby_line_edit: LineEdit = $"../LobbyLineEdit"
var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var id: int = 0


func _process(_delta: float) -> void:
	peer.poll()
	
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
			if data.message == Message.id:
				id = int(data.id)
			
			print(data)


func _connect_to_server(_ip: String) -> void:
	var err = peer.create_client("ws://127.0.0.1:9999")
	
	if err:
		printerr(err)
		return
	
	print("started client")


func _on_client_btn_pressed() -> void:
	_connect_to_server("")


func _on_send_packet_pressed() -> void:
	var message = {
		"message": Message.join,
		"data": "test"
	}
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(message_bytes)


func _on_lobby_btn_pressed() -> void:
	var message = {
		"id": id,
		"message": Message.lobby,
		"lobby_value": lobby_line_edit.text
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
