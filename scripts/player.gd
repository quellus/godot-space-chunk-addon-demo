extends CharacterBody3D


const SPEED: float = 10 # m/s
const ACCELERATION: float = 100 # m/s^2
@onready var camera: Camera3D = $Camera3D
var walk_velocity: Vector3 = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"exit"):
		get_tree().quit()
	elif event is InputEventMouseMotion:
		var look_dir = event.relative * 0.001
		camera.rotation.y -= look_dir.x
		camera.rotation.x = clamp(camera.rotation.x - look_dir.y, -1.5, 1.5)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var move_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	var forward = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir = forward.normalized()
	walk_velocity = walk_velocity.move_toward(walk_dir * SPEED * move_dir.length(), ACCELERATION * delta)
	velocity = walk_velocity
	move_and_slide()
