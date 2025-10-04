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

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()


func _process(_delta: float) -> void:
	peer.poll()
	
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
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
