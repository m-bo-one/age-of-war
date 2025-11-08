extends Control


@onready var net_selection = $Panel/VBoxContainer/NetSelection
@onready var lan = $Panel/VBoxContainer/Lan


func show_lan_menu():
    $Panel/VBoxContainer/BtnLan.hide()
    $Panel/VBoxContainer/Spacer4.hide()
    $Panel/VBoxContainer/BtnSteam.hide()
    $Panel/VBoxContainer/Spacer5.hide()
    lan.show()
    
    $Panel/VBoxContainer/BtnReturn.set_text("Click here to return to the multiplayer menu")

    
func hide_lan_menu():
    $Panel/VBoxContainer/BtnLan.show()
    $Panel/VBoxContainer/Spacer4.show()
    $Panel/VBoxContainer/BtnSteam.show()
    $Panel/VBoxContainer/Spacer5.show()
    lan.hide()
    
    $Panel/VBoxContainer/BtnReturn.set_text("Click here to return to the menu")


func _on_btn_lan_pressed() -> void:
    show_lan_menu()


func _on_btn_steam_pressed() -> void:
    pass # Replace with function body.


func _on_return_pressed() -> void:
    if multiplayer.has_multiplayer_peer():
        multiplayer.multiplayer_peer.close()

    if lan.visible:
        hide_lan_menu()
    else:
        get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
