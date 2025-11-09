extends Control


@onready var sync: MultiplayerSynchronizer = $MultiplayerSynchronizer


func _ready() -> void:
    sync.root_path = "..."
    sync.replication_interval = 0.1
    
    if not multiplayer.has_multiplayer_peer():
        return
    
    var conf: SceneReplicationConfig = sync.replication_config
    
    var init_props = [
        ".:position",
        ".:health",
        ".:damage",
        "AnimatedSprite2D:animation",
        "AnimatedSprite2D:flip_h",
        "AnimatedSprite2D:frame",
    ]
    
    for prop in init_props:
        conf.add_property(prop)
        conf.property_set_replication_mode(prop, SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
    #
    #for prop in conf.get_properties():
        #print("US prop: ", prop)
