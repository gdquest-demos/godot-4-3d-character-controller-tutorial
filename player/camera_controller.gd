@tool
class_name CameraController3D
extends Node3D

enum CameraPivot { OVER_SHOULDER, THIRD_PERSON }

## If true, the camera will invert the Y axis of the mouse input.
## Moving the joystick or mouse up will move the camera down.
@export var invert_mouse_y := true
## Factor that multiplies the mouse input.
## Greater values will make the camera move faster when using the mouse.
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
## Factor that multiplies the joystick input.
## Greater values will make the camera move faster when using a joystick.
@export_range(0.0, 8.0) var joystick_sensitivity := 3.0
@export var tilt_upper_limit := -PI / 3.0
@export var tilt_lower_limit := PI / 3.0

## Reference to the camera node controlled by the camera controller (and the player).
## This is exposed to easily access the camera basis.
@onready var camera: Camera3D = %Camera3D

@onready var _camera_spring_arm: SpringArm3D = %SpringArm3D
@onready var _third_person_pivot: Node3D = %PivotThirdPerson
@onready var _over_shoulder_pivot: Node3D = %PivotOverShoulder
@onready var _camera_raycast: RayCast3D = %RayCast3D

var _aim_target : Vector3
var _pivot_node: Node3D
var _current_pivot_type: CameraPivot
var _input_direction := Vector2.ZERO
var _player: CharacterBody3D


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		set_process_unhandled_input(false)
		return

	set_physics_process(camera != null and _player != null)


func _unhandled_input(event: InputEvent) -> void:
	var player_is_using_mouse := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if player_is_using_mouse:
		_input_direction.x = -event.relative.x * mouse_sensitivity
		_input_direction.y = -event.relative.y * mouse_sensitivity


func _physics_process(delta: float) -> void:
	# Adding joystick input like this makes the camera automatically work with
	# both mouse and joystick.
	_input_direction.x += Input.get_axis("camera_left", "camera_right") * joystick_sensitivity
	_input_direction.y += Input.get_axis("camera_up", "camera_down") * joystick_sensitivity
	if invert_mouse_y:
		_input_direction.y *= -1.0

	if _camera_raycast.is_colliding():
		_aim_target = _camera_raycast.get_collision_point()
	else:
		_aim_target = _camera_raycast.global_transform * _camera_raycast.target_position

	# Set camera controller to current ground level for the character
	global_position = _player.global_position
	global_position.y = lerp(global_position.y, _player.ground_height, 1.0 * delta)

	# Rotates camera using euler rotation
	rotation.x += _input_direction.y * delta
	rotation.x = clamp(rotation.x, tilt_lower_limit, tilt_upper_limit)
	rotation.y += _input_direction.x * delta

	camera.global_transform = _pivot_node.global_transform
	camera.rotation.z = 0.0

	_input_direction.x = 0.0
	_input_direction.y = 0.0


func setup(anchor: Player3D) -> void:
	_player = anchor
	if not camera:
		await ready
	global_position = _player.global_position
	_camera_spring_arm.add_excluded_object(_player.get_rid())
	_camera_spring_arm.spring_length = _player.camera_distance
	_camera_raycast.add_exception_rid(_player.get_rid())
	set_pivot(CameraPivot.THIRD_PERSON)
	set_physics_process(not Engine.is_editor_hint())

	rotation.y = _player.rotation.y
	camera.global_transform = _pivot_node.global_transform


func set_pivot(new_pivot: CameraPivot) -> void:
	if new_pivot == _current_pivot_type:
		return

	if new_pivot == CameraPivot.OVER_SHOULDER:
		_over_shoulder_pivot.look_at(_aim_target)
		_pivot_node = _over_shoulder_pivot
	elif new_pivot == CameraPivot.THIRD_PERSON:
		_pivot_node = _third_person_pivot

	_current_pivot_type = new_pivot


func get_aim_target() -> Vector3:
	return _aim_target
