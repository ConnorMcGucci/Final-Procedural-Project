extends CharacterBody3D

@export var MOVE_SPEED: float = 50.0
@export var first_person: bool = false:
	set(p_value):
		first_person = p_value
		if first_person:
			var tween: Tween = create_tween()
			tween.tween_property($CameraManager/Arm, "spring_length", 0.0, .33)
			tween.tween_callback($Body.set_visible.bind(false))
		else:
			$Body.visible = true
			create_tween().tween_property($CameraManager/Arm, "spring_length", 6.0, .33)
			
@export var collision_enabled: bool = true:
	set(p_value):
		collision_enabled = p_value
		$CollisionShapeBody.disabled = !collision_enabled
		$CollisionShapeRay.disabled = !collision_enabled


func _physics_process(p_delta) -> void:
	var direction: Vector3 = get_camera_relative_input()
	var h_veloc: Vector2 = Vector2(direction.x, direction.z) * MOVE_SPEED

	# Handle horizontal and vertical movement
	velocity.x = h_veloc.x
	velocity.z = h_veloc.y

	# Shift key for downward movement
	if Input.is_key_pressed(KEY_SHIFT):
		velocity.y = -MOVE_SPEED
	elif Input.is_key_pressed(KEY_SPACE):  # Optional: SPACE for upward movement
		velocity.y = MOVE_SPEED
	else:
		velocity.y = 0  # Reset vertical velocity when no key is pressed

	move_and_slide()

# Returns the input vector relative to the camera. Forward is always the direction the camera is facing
func get_camera_relative_input() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	var camera_node = $CameraManager/Arm/Camera3D
	if Input.is_key_pressed(KEY_A):  # Left
		input_dir -= camera_node.global_transform.basis.x
	elif Input.is_key_pressed(KEY_D):  # Right
		input_dir += camera_node.global_transform.basis.x
	elif Input.is_key_pressed(KEY_W):  # Forward
		input_dir -= camera_node.global_transform.basis.z
	elif Input.is_key_pressed(KEY_S):  # Backward
		input_dir += camera_node.global_transform.basis.z
	return input_dir

func _input(p_event: InputEvent) -> void:
	if p_event is InputEventMouseButton and p_event.pressed:
		if p_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			MOVE_SPEED = clamp(MOVE_SPEED + 5, 5, 9999)
		elif p_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			MOVE_SPEED = clamp(MOVE_SPEED - 5, 5, 9999)

	elif p_event is InputEventKey:
		if p_event.pressed:
			if p_event.keycode == KEY_V:
				first_person = !first_person
			elif p_event.keycode == KEY_C:
				collision_enabled = !collision_enabled

		# Reset vertical velocity when up/down keys are released
		elif p_event.keycode in [KEY_Q, KEY_E, KEY_SPACE, KEY_SHIFT]:
			velocity.y = 0
