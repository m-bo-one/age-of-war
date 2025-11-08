extends Node


const IP_ADDRESS: String = "127.0.0.1"
const PORT: int = 14777
const MAX_CLIENTS: int = 2 # always 2


func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if multiplayer.has_multiplayer_peer():
            if multiplayer.is_server():
                print("[PEER]=", multiplayer.get_unique_id(), " - closing peer on server")
                multiplayer.multiplayer_peer.close()
            else:
                print("[PEER]=", multiplayer.get_unique_id(), " - closing peer for client on server")
                multiplayer.multiplayer_peer.disconnect_peer(1, false)


func get_local_ip() -> String:
    var ip = ""
    for address in IP.get_local_addresses():
        if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
            if address.begins_with("192.168.") or address.begins_with("10.") or (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
                ip = address
                break
    return ip
    
    
func stop_peer() -> void:
    var peer = multiplayer.get_multiplayer_peer()
    if not peer:
        return

    peer.close()
    multiplayer.set_multiplayer_peer(null)
    return


func create_server(ip_address: String = IP_ADDRESS, port: int = PORT) -> Error:
    var peer = ENetMultiplayerPeer.new()
    
    var err = peer.create_server(port, MAX_CLIENTS)
    if err != OK:
        printerr("failed to create server: ", err)
        return err
        
    peer.set_bind_ip(ip_address)
        
    multiplayer.set_multiplayer_peer(peer)
    return OK


func create_client(ip_address: String = IP_ADDRESS, port: int = PORT) -> Error:
    var peer = ENetMultiplayerPeer.new()
    
    var err = peer.create_client(ip_address, port)
    if err != OK:
        printerr("failed to create client: ", err)
        return err

    multiplayer.set_multiplayer_peer(peer)
    return OK
