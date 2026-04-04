class_name SpaceChunk extends Node3D

const CHUNK_SIZE: int = 16
const SPACE_OBJECT = preload("res://scenes/space_object.tscn")

var chunk_coord: Vector3i = Vector3i.ZERO:
	set(value):
		chunk_coord = value
		global_position = Vector3(value) * CHUNK_SIZE

var fast_noise_lite: FastNoiseLite = load("res://resources/new_fast_noise_lite.tres")

var rng = RandomNumberGenerator.new()

func generate() -> void:
	for x in range(-CHUNK_SIZE, CHUNK_SIZE):
		for y in range(-CHUNK_SIZE, CHUNK_SIZE):
			for z in range(-CHUNK_SIZE, CHUNK_SIZE):
				var global_coords: Vector3 = Vector3(global_position.x + x,global_position.y + y,global_position.z + z)
				var noise_val = fast_noise_lite.get_noise_3dv(global_coords)
				if  noise_val > 0.67:
					var space_object = SPACE_OBJECT.instantiate()
					add_child(space_object);
					space_object.global_position = global_coords
