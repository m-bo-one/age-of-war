extends Control


@onready var net_selection = $Panel/VBoxContainer/NetSelection
@onready var lan = $Panel/VBoxContainer/Lan


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_btn_lan_pressed() -> void:
    net_selection.hide()
    lan.show()


func _on_btn_steam_pressed() -> void:
    pass # Replace with function body.
