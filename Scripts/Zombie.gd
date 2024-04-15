extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hit_animplayer: AnimationPlayer = $HitFlashAnimationPlayer
@export var SPEED = 1
@export var HEALTH = 3
var isNavLoaded
	
func _ready():
	await get_tree().physics_frame
	
func _physics_process(_delta):
	if not isNavLoaded:
		isNavLoaded = true
		return
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()  * SPEED
	look_at(nav_agent.target_position)
	velocity = new_velocity
	move_and_slide()

func take_damage():
	HEALTH -= 1
	print("Zombie got hurt, health left:")
	print(HEALTH)
	hit_animplayer.play("Hit_flash")
	if (HEALTH <= 0):
		queue_free()
		
func update_target_location(target_location):
	nav_agent.target_position = target_location
