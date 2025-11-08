extends Control


func _on_return_pressed():
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_btn_single_pressed() -> void:
    GlobalVariables.reset()
    get_tree().change_scene_to_file("res://scenes/difficulty_selection.tscn")


func _on_btn_multi_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/multiplayer/multiplayer_menu.tscn")
