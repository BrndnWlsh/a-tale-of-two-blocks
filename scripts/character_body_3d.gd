extends CharacterBody3D


## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false


@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.0007
## Normal speed.
@export var base_speed : float = 3.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we freefly?
@export var freefly_speed : float = 15.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "Left"
## Name of Input Action to move Right.
@export var input_right : String = "Right"
## Name of Input Action to move Forward.
@export var input_forward : String = "Forward"
## Name of Input Action to move Backward.
@export var input_back : String = "Back"
## Name of Input Action to Jump.
@export var input_jump : String = "Jump"
## Name of Input Action to Descend.
@export var input_descend : String = "Descend"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "Freefly"
@export var input_pause : String = "Pause"
@export var input_perspective : String = "Toggle Perspective"

var double_jump_available = false
var mouse_captured : bool = false
var look_rotation : Vector2
var freeflying : bool = false
var can_break = true
var can_build = true
var block_id = 0
var timeout = .2
enum perspectives {first, third}
var perspective = perspectives.first

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collider: CollisionShape3D = $Collider
@onready var raycast: RayCast3D = $Head/RayCast3D
@onready var hotbar: ItemList = $Hotbar
const OUTLINE = preload("uid://v7sb6q003lj5")


func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	capture_mouse()
	
func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if mouse_captured:
			breakBlock()
		else:
			capture_mouse()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if mouse_captured:
			buildBlock()
	if Input.is_action_just_pressed(input_pause):
		if !$"../PauseMenu".visible:
			release_mouse()
			$"../PauseMenu".visible = true
			$"../Crosshair".visible = false
			$Hotbar.visible = false
		else:
			capture_mouse()
			$"../PauseMenu".visible = false
			$"../Crosshair".visible = true
			$Hotbar.visible = true
	for n in range(1,10):
		if Input.is_action_just_pressed("Hotbar Slot %s" % n):
				hotbar.select(n-1)
	if Input.is_action_just_pressed(input_perspective):
		if perspective == perspectives.first:
			camera.position = Vector3(1,1.5,3)
			perspective = perspectives.third
		else:
			camera.position = Vector3(0,.5,0)
			perspective = perspectives.first

	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var vert_dir := int(Input.is_action_pressed(input_jump)) - int(Input.is_action_pressed(input_descend))
		var motion := (head.global_basis * Vector3(input_dir.x, vert_dir, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Handle jump.
	if can_jump:
		if Input.is_action_just_pressed("Jump") and (is_on_floor() or double_jump_available):
			velocity.y = jump_velocity
			if !double_jump_available:
				double_jump_available = true
			else:
				double_jump_available = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * base_speed
			velocity.z = direction.z * base_speed
		else:
				velocity.x = move_toward(velocity.x, 0, base_speed)
				velocity.z = move_toward(velocity.z, 0, base_speed)
	else:
		velocity.x = 0
		velocity.y = 0

	move_and_slide()

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().create_timer(0.1).timeout
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func breakBlock():
	if raycast.is_colliding():
		#print("raycast colliding")
		var break_collider = raycast.get_collider()
		if break_collider is GridMap and can_break:
			var collisionPoint = raycast.get_collision_point()
			var local_collision_point = break_collider.local_to_map(collisionPoint)
			if break_collider.get_cell_item(break_collider.local_to_map(collisionPoint)) == -1:
				local_collision_point = break_collider.local_to_map(collisionPoint + Vector3(-0.01 , -0.01, -0.01))
			break_collider.set_cell_item(local_collision_point, -1)
			can_break = false
			await get_tree().create_timer(timeout).timeout
			can_break = true
			print("block broken at ", local_collision_point)

func buildBlock():
	if raycast.is_colliding():
		var build_collider = raycast.get_collider()
		if build_collider is GridMap and can_build:
			var collisionPoint = raycast.get_collision_point()
			if build_collider.get_cell_item(build_collider.local_to_map(collisionPoint)) != -1:
				build_collider.set_cell_item(build_collider.local_to_map(collisionPoint + raycast.get_collision_normal()), $Hotbar.get_selected_items()[0])	
			else:
				build_collider.set_cell_item(build_collider.local_to_map(collisionPoint), $Hotbar.get_selected_items()[0])
			if can_build:
				can_build = false
				await get_tree().create_timer(timeout).timeout
				can_build = true

func highlightBlock():
	var override_material = ShaderMaterial.new()
	override_material.shader = OUTLINE
#	var highlight_collider = raycast.get_collider()
#	if highlight_collider is GridMap:
#		var collisionPoint = highlight_collider.local_to_map(raycast.get_collision_point())
#		highlight_collider
	
	%MeshInstance3D.set_surface_override_material(0, override_material)

## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false
