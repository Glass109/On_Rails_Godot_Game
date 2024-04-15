extends Node3D
@onready var Player = $Player

func _physics_process(_delta):
	get_tree().call_group("enemies","update_target_location", Player.global_transform.origin)
