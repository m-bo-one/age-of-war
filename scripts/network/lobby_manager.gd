extends Node


enum Status {START}
enum BaseSide {LEFT = 1, RIGHT}


signal on_lobby_status_update(status: Status)


const Player = preload("res://scripts/network/player.gd")

var _active_player: Player = null
var _players: Array[Player] = [null, null]
var _player_pos: Dictionary[int, int] = {}
# max capacity for lobby
var _max_size = 2
        
        
func reset() -> void:
    _players = [null, null]
    _player_pos = {}
    
    
func get_player(id: int) -> Player:
    if not has_player(id):
        return null
        
    return _players[_player_pos[id]]
    
    
func get_opponent_player(id: int) -> Player:
    if not is_full():
        return

    if _player_pos[id] == 0:
        return _players[1]
    return _players[0]

    
func has_player(id: int) -> bool:
    return _player_pos.has(id)
    

func is_full() -> bool:
    return len(_player_pos) == _max_size
    
    
# should be used only after max_size check
func get_random_base_side() -> BaseSide:
    var rnd = RandomNumberGenerator.new()
    #var base_side: BaseSide = rnd.randi_range(BaseSide.LEFT, BaseSide.RIGHT)
    var base_side = 0
    
    print("_players", _players)

    if _players[0] == null:
        base_side = BaseSide.LEFT
    else:
        base_side = BaseSide.RIGHT
    
    return base_side
        
        
func try_start() -> bool:
    if not is_full():
        return false
        
    send_status_info.rpc(Status.START)
    
    return true
    
    
func get_status_display(status: Status) -> String:
    if status == Status.START:
        return "starting game"
    return "no status"
    
    
@rpc("any_peer", "call_local")
func send_status_info(status: Status) -> void:
    print("[PEER]=", multiplayer.get_unique_id(), " - status info update: ", status)
    on_lobby_status_update.emit(status)
    
    
func get_active_player() -> Player:
    return _active_player
    
    
@rpc("any_peer")
func set_active_player(data: Dictionary) -> void:
    print("[PEER]=", multiplayer.get_unique_id(), " - active player set: ", data.id)
    _active_player = Player.new(data.id, data.name, data.base_side)


@rpc("any_peer")
func join(id: int, name: String) -> void:
    if is_full():
        return
        
    if has_player(id):
        return
        
    var base_side = get_random_base_side()
    var player = Player.new(id, name, base_side)
    # position - 1 as counting from 1
    var position = base_side - 1
    _players[position] = player
    _player_pos[id] = position
    
    print("[PEER]=", multiplayer.get_unique_id(), " - player joined: ", player.to_dict())
    
    if multiplayer.is_server():
        if id != 1:
            set_active_player.rpc_id(id, player.to_dict())
        else:
            set_active_player(player.to_dict())
    

@rpc("any_peer")
func exit(id: int) -> void:
    if not has_player(id):
        return
        
    var pos = _player_pos[id]
    _players[pos] = null
    _player_pos.erase(id)
    
    print("[PEER]=", multiplayer.get_unique_id(), " - player exit: ", id)
    

## Update global state and player data
@rpc("authority", "call_local")
func update_money(id: int, amount: int) -> void:
    #var player = get_player(id)
    #print("update_money: player: ", id, player)
    GlobalVariables.player_money += amount
    GlobalVariables.player_exp += 2 * amount
    
    #player.money = GlobalVariables.player_money
    #player.exp = GlobalVariables.player_exp


## Update global state and player data
@rpc("authority", "call_local")
func deduct_money(id: int, type: String) -> void:
    print("[PEER]=", multiplayer.get_unique_id(), " - deduct_money: player: ", id)
    GlobalVariables.player_money -= GlobalVariables.get_unit_cost(type, GlobalVariables.current_stage)
    #var player = get_player(id)
    #deduct_money_local(id, type)
    #player.money = GlobalVariables.player_money
    #deduct_money_local.rpc_id(id, id, type)
