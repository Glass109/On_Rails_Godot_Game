extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = .03

signal gun_shooted

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var looking_angle : Vector2
var viewport : Viewport
var canShoot := false
var rayOrigin
var rayEnd
var isShooting
var intersection
var bulletFired := false
@onready var head : Node3D = $Head
@onready var camera : Camera3D = $Head/Camera3D
@onready var gun : Node3D = $Head/Camera3D/ThompsonGun
@onready var fire_rate : Timer = $fire_rate

func _ready():
	viewport = get_viewport()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
func _process(delta):
	if isShooting and canShoot:
		bulletFired = true
		emit_signal("gun_shooted")
		check_if_enemy_hit()
		canShoot = false
		
func aim_gun_towards_cursor():
	var mouse_position = viewport.get_mouse_position()
	rayOrigin = camera.project_ray_origin(mouse_position)
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * 2000
	intersection = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd))
	if not intersection.is_empty():
		var pos = intersection.position
		gun.look_at(Vector3(pos.x, pos.y, pos.z))
	
func check_if_enemy_hit():
	if intersection.is_empty(): return
	var collided_node : Node = intersection.collider
	if collided_node.is_in_group("enemies") and bulletFired:
			collided_node.take_damage()
	bulletFired = false
	
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var viewport_center = viewport.get_visible_rect().size / 2
		looking_angle =  ((viewport.get_mouse_position()) - (viewport_center)) / viewport_center
		looking_angle.x = looking_angle.x if abs(looking_angle.x) > 0.7 else 0.0
		looking_angle.y = looking_angle.y if abs(looking_angle.y) > 0.7 else 0.0
	if event is InputEventMouseButton:
		isShooting = true if Input.is_action_pressed("Shoot") else false
		

		
func _physics_process(delta):

	head.rotate_y(-looking_angle[0] * SENSITIVITY)
	camera.rotate_x(-looking_angle[1] * SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-20), deg_to_rad(20))
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	aim_gun_towards_cursor()
	
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("SidestepLeft", "SidestepRight", "Foward", "Backwards")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()


func _on_fire_rate_timeout():
	canShoot = true # Replace with function body.
