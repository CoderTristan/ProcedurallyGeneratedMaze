extends CharacterBody3D

@onready var cam = %Camera3D
@onready var collider = %CollisionShape3D

var SPEED = 8
@export var marker_scene: PackedScene = preload("res://scenes/marker.tscn") 

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_place_marker()
		

func _physics_process(delta: float) -> void:
	var input_dir_2d = Input.get_vector("left", "right", "forward", "backward")
	var input_dir_3d = Vector3(input_dir_2d.x, 0, input_dir_2d.y)
	var direction = transform.basis * input_dir_3d

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	velocity.y -= 20.0 * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		cam.rotation_degrees.x -= event.relative.y * 0.2
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -60.0, 60.0)

func _place_marker() -> void:
	var from = cam.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + cam.project_ray_normal(get_viewport().get_mouse_position()) * 1000.0

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result: Dictionary = space_state.intersect_ray(query)
	if result.size() > 0:
		var hit_pos: Vector3 = result["position"]
		var marker := marker_scene.instantiate()
		marker.position = hit_pos
		get_tree().current_scene.add_child(marker)
