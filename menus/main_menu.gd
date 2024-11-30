extends Control

var lobby_browser_scene : PackedScene = load("res://menus/lobby_browser/lobby_browser.tscn")
var lobby_creator_scene : PackedScene = load("res://menus/lobby_creator.tscn")
var reconnects = 0

@export var peer_name_line_edit : LineEdit
@export var lobby_connection_label : Label
@export var logs : Label
@export var menu: VBoxContainer
@export var set_name_menu: VBoxContainer
func _ready() -> void:
	GlobalLobbyClient.disconnected_from_lobby.connect(_on_disconnect)
	connect_to_lobby()
	peer_name_line_edit.text = GlobalLobbyClient.peer.peer_name
	menu.visible = GlobalLobbyClient.peer.peer_name != ""

func connect_to_lobby():
	#GlobalLobbyClient.server_url = "ws://localhost:8080/connect"
	var connected = GlobalLobbyClient.connect_to_lobby("hangman")
	if connected:
		lobby_connection_label.text = "Lobby Service: Connected"
	
func _on_disconnect():
	lobby_connection_label.text = "Lobby Service: Retrying"
	if reconnects > 5:
		push_error("Cannot connect")
		return
	reconnects += 1
	await get_tree().create_timer(0.5 * reconnects).timeout
	connect_to_lobby()

func _on_button_join_public_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_browser_scene)


func _on_button_lobby_pressed() -> void:
	get_tree().change_scene_to_packed(lobby_creator_scene)


func _on_set_name_pressed() -> void:
	var result :LobbyResult= await GlobalLobbyClient.set_peer_name(peer_name_line_edit.text).finished
	if result.has_error():
		logs.text = result.error
	else:
		logs.text = "Success"
		menu.visible = true
		set_name_menu.visible = false
