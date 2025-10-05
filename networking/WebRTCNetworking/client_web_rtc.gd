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
var web_rtc_peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var id: int = 0
var lobby_value: String = ""


func _process(_delta: float) -> void:
	peer.poll()
	
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
			if data.message == Message.id:
				print(data)
				id = int(data.id)
				_connected(id)
			
			if data.message == Message.userConnected:
				_create_peer(data.id) 
			
			if data.message == Message.lobby:
				print(JSON.parse_string(data.players))
				lobby_value = data.lobby_value
			
			
			if data.message == Message.candidate:
				if web_rtc_peer.has_peer(data.original_peer):
					print("new candidate: " + str(data.original_peer) + " my id is " + str(id))
					web_rtc_peer.get_peer(data.original_peer).connection.add_ice_candidate(data.media, data.index, data.sdp)
			
			if data.message == Message.offer:
				if web_rtc_peer.has_peer(data.original_peer):
					web_rtc_peer.get_peer(data.original_peer).connection.set_remote_description("offer", data.sdp)
			
			
			if data.message == Message.answer:
				if web_rtc_peer.has_peer(data.original_peer):
					web_rtc_peer.get_peer(data.original_peer).connection.set_remote_description("offer", data.sdp)


func _connected(peer_id):
	web_rtc_peer.create_mesh(peer_id)
	multiplayer.multiplayer_peer = web_rtc_peer


#region webRTC methods
func _create_peer(peer_id: int) -> void:
	if peer_id != self.id:
		# describe the peer connection
		var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{"urls": ["stun:stun.l.google.com:19302"]}]
		})
		print("binding id " + str(id) + " my id " + str(self.id))
		peer.session_description_created.connect(_on_session_description_connected.bind(peer_id))
		peer.ice_candidate_created.connect(_on_ice_candidate_created.bind(peer_id))
		web_rtc_peer.add_peer(peer, peer_id)
		
		if peer_id < web_rtc_peer.get_unique_id():
			peer.create_offer()


func _on_session_description_connected(type: String, sdp: String, peer_id: int) -> void:
	if not web_rtc_peer.has_peer(peer_id):
		return
	
	web_rtc_peer.get_peer(peer_id).connection.set_local_description(type, sdp)
	
	if type == "offer":
		_send_offer(peer_id, sdp)
	else:
		_send_answer(peer_id, sdp)


func _send_offer(peer_id: int, sdp: String) -> void:
	var message = {
		"id": peer_id,
		"original_peer": self.id,
		"message": Message.offer,
		"sdp": sdp,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	

func _send_answer(peer_id: int, sdp: String) -> void:
	var message = {
		"id": peer_id,
		"original_peer": self.id,
		"message": Message.answer,
		"sdp": sdp,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())


func _on_ice_candidate_created(media: String, index: int, name: String, peer_id: int) -> void:
	var message = {
		"id": peer_id,
		"original_peer": self.id,
		"message": Message.candidate,
		"index": index,
		"media": media,
		"sdp": name,
		"lobby_value": lobby_value
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
#endregion


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
