extends Control


enum menu {root, unit, turret, sell_turret, add_turret_spot}

var current_menu
var queue : Array = []
var loading_unit = false
var load_finish = false

var main_node_path: String = "/root/multiplayer_game"

signal spawn_melee
signal spawn_range
signal spawn_tank
signal spawn_super_soldier

# Called when the node enters the scene tree for the first time.
func _ready():
    current_menu = menu.root
    $default_menu/root_hbox_container.show()
    $units_menu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    update_queue_hud()
    if queue.size() != 0 and loading_unit == false:
        loading_unit = true
        load_first_unit_in_queue()
    if queue.size() != 0 and loading_unit == true and get_node(main_node_path).unable_to_spawn == false and load_finish == true:
        _tween_queue_finished(queue[0][0], queue[0][2])
    if loading_unit == true and load_finish == true:
        $sublabel_queue.text = "Waiting for space"
    elif loading_unit == true:
        $sublabel_queue.show()
    else:
        $sublabel_queue.hide()


func _on_unit_pressed():
    # Enter unit menu
    $default_menu/root_hbox_container.hide()
    $units_menu.show()
    current_menu = menu.unit
    pass # Replace with function body.


func _on_back_pressed():
    if current_menu != menu.root:
        $units_menu/Label.text = ""
        current_menu = menu.root
        $default_menu/root_hbox_container.show()
        $units_menu.hide()


func _on_advance_pressed():
    if GlobalVariables.player_exp >= GlobalVariables.get_exp_to_next_age():
        GlobalVariables.current_stage += 1
        update_sprites_with_age()
        var player = LobbyManager.get_active_player()
        var base_node = get_node(main_node_path + "/player_" + str(player.base_side) + "_base")
        base_node.advance_base_sprite.rpc(GlobalVariables.current_stage)
        if GlobalVariables.current_stage == GlobalVariables.stage.future:
            $units_menu/HBoxContainer/special.disabled = false
    else:
        $root_label.show()
        $root_label.text = "Not enough XP!"


func update_sprites_with_age():
    if GlobalVariables.current_stage == GlobalVariables.stage.knight:
        $units_menu/units_UI.texture = load("res://age of war sprites/ui/units_buttons0002.png")
        %SpecialButtonSprite.texture = load("res://age of war sprites/ui/special_buttons0002.png")
    elif GlobalVariables.current_stage == GlobalVariables.stage.medival:
        $units_menu/units_UI.texture = load("res://age of war sprites/ui/units_buttons0003.png")
        %SpecialButtonSprite.texture = load("res://age of war sprites/ui/special_buttons0003.png")
    elif GlobalVariables.current_stage == GlobalVariables.stage.miltary:
        $units_menu/units_UI.texture = load("res://age of war sprites/ui/units_buttons0004.png")
        %SpecialButtonSprite.texture = load("res://age of war sprites/ui/special_buttons0004.png")
    elif GlobalVariables.current_stage == GlobalVariables.stage.future:
        $units_menu/units_UI.texture = load("res://age of war sprites/ui/units_buttons0005.png")
        %SpecialButtonSprite.texture = load("res://age of war sprites/ui/special_buttons0005.png")
        $default_menu/root_hbox_container/advance.disabled = true

func add_to_queue(type: String, load_time: float, stage: String):
    if queue.size() >= 5:
        return
    queue.append([type, load_time, stage])

func load_first_unit_in_queue():
    load_finish = false
    var unit = queue[0]
    var type = unit[0]
    var time_to_load = unit[1]
    var stage = unit[2]
    var tween = create_tween()
    tween.tween_property($queue/ColorRect7, "size", Vector2(432, 16), time_to_load)
    tween.connect("finished", _tween_queue_finished.bind(type, stage))
    tween.play()
    $sublabel_queue.text = "Training " + GlobalVariables.get_unit_name(type, stage) + "..."
    

func queue_load(time, unit: String):
    if queue.size() != 0:
        return
    var tween = create_tween()
    tween.tween_property($queue/ColorRect7, "size", Vector2(432, 16), time)
    tween.connect("finished", _tween_queue_finished.bind(unit))
    tween.play()


func _tween_queue_finished(unit: String, stage: String):
    if get_node(main_node_path).unable_to_spawn == false:
        emit_signal("spawn_" + unit, stage)
        $queue/ColorRect7.size.x = 0
        loading_unit = false
        queue.pop_front()
        load_finish = false
    else:
        load_finish = true
    
    
func _on_troop_pressed(type: String, load_time: float) -> void:
    if GlobalVariables.player_money >= GlobalVariables.get_unit_cost(type, GlobalVariables.current_stage):
        if queue.size() < 5:
            LobbyManager.deduct_money(multiplayer.get_unique_id(), type)
            var stage = GlobalVariables.get_age_as_string(GlobalVariables.current_stage)
            add_to_queue(type, 0.5, stage)
    else:
        $units_menu/Label.show()
        $units_menu/Label.text = "Not enough money!"


func _on_melee_pressed():
    _on_troop_pressed("melee", 0.5)


func _on_range_pressed():
    _on_troop_pressed("melee", 1.0)


func _on_tank_pressed():
    _on_troop_pressed("tank", 2.0)

    
func _on_special_pressed():
    _on_troop_pressed("super_soldier", 10.0)


func _on_special_button_pressed():
    if GlobalVariables.current_stage == GlobalVariables.stage.cave:
        get_node(main_node_path).cave_special_attack()
        get_node(main_node_path + "/Camera2D").apply_shake()
    elif GlobalVariables.current_stage == GlobalVariables.stage.knight:
        get_node(main_node_path).knight_special_attack()
        get_node(main_node_path + "/Camera2D").apply_shake()
    elif GlobalVariables.current_stage == GlobalVariables.stage.medival:
        get_node(main_node_path).medival_special_attack()
    elif GlobalVariables.current_stage == GlobalVariables.stage.miltary:
        get_node(main_node_path).miltary_special_attack()
        get_node(main_node_path + "/Camera2D").apply_shake()
    elif GlobalVariables.current_stage == GlobalVariables.stage.future:
        get_node(main_node_path).future_special_attack()
        get_node(main_node_path + "/Camera2D").apply_shake()



func update_queue_hud():
    if queue.size() == 0:
        $queue/HBoxContainer/ColorRect.hide()
        $queue/HBoxContainer/ColorRect2.hide()
        $queue/HBoxContainer/ColorRect3.hide()
        $queue/HBoxContainer/ColorRect4.hide()
        $queue/HBoxContainer/ColorRect5.hide()
    elif queue.size() == 1:
        $queue/HBoxContainer/ColorRect.show()
        $queue/HBoxContainer/ColorRect2.hide()
        $queue/HBoxContainer/ColorRect3.hide()
        $queue/HBoxContainer/ColorRect4.hide()
        $queue/HBoxContainer/ColorRect5.hide()
    elif queue.size() == 2: 
        $queue/HBoxContainer/ColorRect.show()
        $queue/HBoxContainer/ColorRect2.show()
        $queue/HBoxContainer/ColorRect3.hide()
        $queue/HBoxContainer/ColorRect4.hide()
        $queue/HBoxContainer/ColorRect5.hide()
    elif queue.size() == 3:
        $queue/HBoxContainer/ColorRect.show()
        $queue/HBoxContainer/ColorRect2.show()
        $queue/HBoxContainer/ColorRect3.show()
        $queue/HBoxContainer/ColorRect4.hide()
        $queue/HBoxContainer/ColorRect5.hide()
    elif queue.size() == 4:
        $queue/HBoxContainer/ColorRect.show()
        $queue/HBoxContainer/ColorRect2.show()
        $queue/HBoxContainer/ColorRect3.show()
        $queue/HBoxContainer/ColorRect4.show()
        $queue/HBoxContainer/ColorRect5.hide()
    elif queue.size() == 5:
        $queue/HBoxContainer/ColorRect.show()
        $queue/HBoxContainer/ColorRect2.show()
        $queue/HBoxContainer/ColorRect3.show()
        $queue/HBoxContainer/ColorRect4.show()
        $queue/HBoxContainer/ColorRect5.show()


func _on_melee_mouse_entered():
    # display melee cost and name
    $units_menu/Label.show()
    $units_menu/Label.text = "${price} - {unit}".format({"price" : GlobalVariables.get_unit_cost("melee", GlobalVariables.current_stage),
                                                        "unit" : GlobalVariables.get_unit_name("melee", GlobalVariables.get_current_age_as_string())})


func _on_unit_button_mouse_exited():
    # hide text
    $units_menu/Label.hide()
    $units_menu/Label.text = ""


func _on_range_mouse_entered():
    $units_menu/Label.show()
    $units_menu/Label.text = "${price} - {unit}".format({"price" : GlobalVariables.get_unit_cost("range", GlobalVariables.current_stage),
                                                        "unit" : GlobalVariables.get_unit_name("range", GlobalVariables.get_current_age_as_string())})


func _on_tank_mouse_entered():
    $units_menu/Label.show()
    $units_menu/Label.text = "${price} - {unit}".format({"price" : GlobalVariables.get_unit_cost("tank", GlobalVariables.current_stage),
                                                        "unit" : GlobalVariables.get_unit_name("tank", GlobalVariables.get_current_age_as_string())})


func _on_unit_mouse_entered():
    $root_label.show()
    $root_label.text = "Train units menu"
    
    
func _on_unit_mouse_exited():
    $root_label.text = ""


func _on_back_mouse_entered():
    $units_menu/Label.show()
    $units_menu/Label.text = "Return to previous menu"


func _on_advance_mouse_entered():
    $root_label.show()
    if GlobalVariables.get_exp_to_next_age() == INF:
        $root_label.text = "Already at max age!"
    else:
        $root_label.text = "{exp} Xp - Evolve to next age".format({"exp": GlobalVariables.get_exp_to_next_age()})



func _on_special_mouse_entered():
    if GlobalVariables.current_stage != GlobalVariables.stage.future:
        return
    $units_menu/Label.show()
    $units_menu/Label.text = "${price} - {unit}".format({"price" : 150000,
                                                        "unit" : "super soldier"})


func _on_special_mouse_exited():
    $units_menu/Label.hide()
    $units_menu/Label.text = ""
