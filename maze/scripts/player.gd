extends CharacterBody3D

@onready var cam = %Camera3D
@onready var collider = %CollisionShape3D

var SPEED = 8

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		

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
