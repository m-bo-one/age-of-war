extends Control


@onready var ip_address_input = $Entry/IP/LineEdit
@onready var port_input = $Entry/Port/LineEdit
@onready var entry = $Entry
@onready var lobby_loader = $LobbyLoader
@onready var error_msg = $LblErr
@onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ip_address_input.placeholder_text = NetworkManager.get_local_ip()
    port_input.placeholder_text = str(NetworkManager.PORT)
    
    multiplayer.connected_to_server.connect(_on_server_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
    
    LobbyManager.on_lobby_status_update.connect(_on_lobby_status_update)
    
    
func get_port_from_input() -> int:
    var port_str: String = port_input.text
    if not port_str:
        port_str = port_input.placeholder_text
        
    print("get parsed port from input: ", port_str)
    var port = port_str.to_int()
    if port == 0:
        printerr("error: not a valid int for port")
        return 0

    return port
    
    
func get_host_from_input() -> String:
    var ip_str: String = ip_address_input.text
    if not ip_str:
        ip_str = ip_address_input.placeholder_text
    print("get parsed ip from input: ", ip_str)
        
    if not ip_str.is_valid_ip_address():
        printerr("error: not a valid ip")
        return ""

    return ip_str

    
func reset_err_msg() -> void:
    error_msg.text = ""
    error_msg.hide()


func _on_btn_create_pressed() -> void:
    reset_err_msg()
    
    NetworkManager.stop_peer()
    LobbyManager.reset()

    var host = get_host_from_input()
    var port = get_port_from_input()
    if host == "" or port == 0:
        return

    var err = NetworkManager.create_server(host, port)
    if err != OK:
        return

    entry.hide()
    lobby_loader.show()
    
    timer.start(1.0)
    LobbyManager.join(1, "")


func _on_btn_connect_pressed() -> void:
    reset_err_msg()
    
    NetworkManager.stop_peer()

    var host = get_host_from_input()
    var port = get_port_from_input()
    NetworkManager.create_client(host, port)
    
    entry.hide()
    lobby_loader.show()


func _on_server_connected() -> void:
    print("[PEER]=", multiplayer.get_unique_id(), "; server connected")
    if not multiplayer.is_server():
        LobbyManager.join.rpc_id(1, multiplayer.get_unique_id(), "")
    

func _on_player_disconnected(id: int) -> void:
    print("[PEER]=", multiplayer.get_unique_id(), "; player disconnected: ", id)
    if multiplayer.is_server():
        LobbyManager.exit(id)
        
        
func _on_server_disconnected() -> void:
    print("[PEER]= server disconnected")
    get_tree().change_scene_to_file("res://scenes/multiplayer/multiplayer_menu.tscn")


func _on_connection_failed() -> void:
    print("[PEER]=", multiplayer.get_unique_id(), "; connection failed")
    error_msg.text = "Failed to establish connection with server"
    error_msg.show()
    
    await get_tree().create_timer(10).timeout
    
    reset_err_msg()


func _on_timer_timeout() -> void:
    if not multiplayer.is_server():
        return

    var ok = LobbyManager.try_start()
    if not ok:
        return
    
    # TODO: Investigate issue of missing peer id if no timer on game start
    #print("[PEER]=", multiplayer.get_unique_id(), "; starting a lobby...")
    timer.stop()


func _on_lobby_status_update(status: LobbyManager.Status) -> void:
    if status == LobbyManager.Status.START:
        _on_game_start(LobbyManager.get_status_display(status))
    

func _on_game_start(msg: String) -> void:
    GlobalVariables.reset_for_multi()
    lobby_loader.get_node("LblAwait").text = msg + "..."

    #await get_tree().create_timer(1).timeout
    
    MusicManager.audioStreamPlayer.play()
    get_tree().change_scene_to_file("res://multiplayer_game.tscn")
