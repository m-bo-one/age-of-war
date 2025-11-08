extends RefCounted
class_name Player

var id: int
var name: String
var base_side: int

var money: int = GlobalVariables.player_money
var stage: int = GlobalVariables.stage.cave
var exp: int = GlobalVariables.player_exp


func _init(id: int, name: String, base_side: int) -> void:
    self.id = id
    self.name = name
    self.base_side = base_side
    
    
func to_dict() -> Dictionary:
    return {
        "id": self.id,
        "name": self.name,
        "base_side": self.base_side,
    }
