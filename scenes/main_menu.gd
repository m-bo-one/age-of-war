extends Control

func _on_play_pressed():
    get_tree().change_scene_to_file("res://scenes/game_selection.tscn")

func _on_instructions_pressed():
    get_tree().change_scene_to_file("res://scenes/instructions_screen.tscn")

func _on_options_pressed():
    get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_extra_pressed():
    get_tree().change_scene_to_file("res://scenes/extra_screen.tscn")

func _on_credits_pressed():
    get_tree().change_scene_to_file("res://scenes/credits_menu.tscn")

func _on_exit_pressed():
    get_tree().quit()
