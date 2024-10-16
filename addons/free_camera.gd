class_name FreelookCamera3D extends Camera3D

@export var movement_speed := 10
@export var mouse_sensitivity := 0.006

var _previous_camera: Camera3D
var _camera_input_direction := Vector2.ZERO


func _ready() -> void:
	current = false
	process_mode = PROCESS_MODE_ALWAYS
	set_process(current)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_freelook_camera"):
		_toggle_camera_mode()

	if current:
		var is_camera_motion := (
			event is InputEventMouseMotion and
			Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		)
		if is_camera_motion:
			_camera_input_direction = event.relative * mouse_sensitivity


func _process(delta: float) -> void:
	var movement := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		movement += Vector3.FORWARD
	if Input.is_key_pressed(KEY_A):
		movement += Vector3.LEFT
	if Input.is_key_pressed(KEY_S):
		movement += Vector3.BACK
	if Input.is_key_pressed(KEY_D):
		movement += Vector3.RIGHT
	if Input.is_key_pressed(KEY_Q):
		movement += Vector3.DOWN
	if Input.is_key_pressed(KEY_E):
		movement += Vector3.UP

	rotation.x -= _camera_input_direction.y
	rotation.x = clampf(rotation.x, -PI / 2.0, PI / 2.0)
	rotation.y -= _camera_input_direction.x

	global_position += global_transform.basis * movement * delta * movement_speed

	_camera_input_direction = Vector2.ZERO


func _toggle_camera_mode() -> void:
	if not current:
		_previous_camera = get_viewport().get_camera_3d()
		fov = _previous_camera.fov
		global_transform = _previous_camera.global_transform
		make_current()
	else:
		_previous_camera.make_current()

	get_tree().paused = current
	set_process(current)
