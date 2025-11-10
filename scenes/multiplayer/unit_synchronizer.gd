extends MultiplayerSynchronizer


func _ready() -> void:
    root_path = ".."
    replication_interval = 0.1
    
    if not multiplayer.has_multiplayer_peer():
        return
    
    var conf: SceneReplicationConfig = replication_config
    
    var init_props = [
        ".:position",
        ".:health",
        ".:max_health",
        ".:damage",
        ".:current_state",
        "AnimatedSprite2D:animation",
        "AnimatedSprite2D:flip_h",
        "AnimatedSprite2D:frame",
        "heal_sprite:visible",
        ".:fog_visible",
    ]
    
    for prop in init_props:
        conf.add_property(prop)
        conf.property_set_replication_mode(prop, SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
    #
    #for prop in conf.get_properties():
        #print("US prop: ", prop)
