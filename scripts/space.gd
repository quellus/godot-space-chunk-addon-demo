class_name Space extends Node3D

@export var space_chunk_scene: PackedScene
@export var focus: Node3D
@export var chunk_radius: int = 3
@export var chunk_size: int = 16

var focus_chunk_coord: Vector3i:
	set(value):
		if value != focus_chunk_coord:
			focus_chunk_coord = value
			_add_chunks_to_gen_queue()
			_add_chunks_to_delete_queue()
			print_debug("Chunk queues updated... Active chunks: ", active_chunks.size(), " Del queue: ", chunk_delete_queue.size(), " Gen queue: ", chunk_generate_queue.size())

var active_chunks: Dictionary[Vector3i, SpaceChunk] = {}
var chunk_delete_queue: Array[SpaceChunk] = []
var chunk_generate_queue: Array[Vector3i] = []

var chunk_process_state: ChunkProcessState = ChunkProcessState.GENERATE
enum ChunkProcessState {
	CHECK,
	DELETE,
	GENERATE
}


func _ready() -> void:
	if is_instance_valid(focus):
		var prev_focus_chunk_coord = focus_chunk_coord
		focus_chunk_coord = Vector3i(focus.global_position / chunk_size)
		if prev_focus_chunk_coord == focus_chunk_coord:
			_add_chunks_to_gen_queue()
			_add_chunks_to_delete_queue()
	else:
		push_error("focus isn't ready yet")


func _process(_delta: float) -> void:
	if is_instance_valid(focus):
		focus_chunk_coord = Vector3i(focus.global_position / chunk_size)
		if chunk_process_state == ChunkProcessState.DELETE:
			if chunk_delete_queue.size() > 0:
				_pop_delete_queue()
			chunk_process_state = ChunkProcessState.GENERATE
		if chunk_process_state == ChunkProcessState.GENERATE:
			if chunk_generate_queue.size() > 0:
				_pop_gen_queue()
			chunk_process_state = ChunkProcessState.DELETE
	else:
		push_error("Space does not have focus")


func _add_chunks_to_gen_queue():
	chunk_generate_queue.clear()
	for x in range(-chunk_radius, chunk_radius):
		for y in range(-chunk_radius, chunk_radius):
			for z in range(-chunk_radius, chunk_radius):
				var chunk_coord: Vector3i = Vector3i(x,y,z) + focus_chunk_coord
				if chunk_coord not in active_chunks or not is_instance_valid(active_chunks[chunk_coord]):
					chunk_generate_queue.append(chunk_coord)


func _add_chunks_to_delete_queue():
	chunk_delete_queue.clear()
	for chunk_coord in active_chunks:
		var distance = chunk_coord - focus_chunk_coord
		if abs(distance.x) > chunk_radius or abs(distance.y) > chunk_radius or abs(distance.z) > chunk_radius:
			chunk_delete_queue.append(active_chunks[chunk_coord])


func _pop_delete_queue():
	var to_delete = chunk_delete_queue.pop_front()
	if is_instance_valid(to_delete) and is_instance_valid(active_chunks[to_delete.chunk_coord]):
		active_chunks.erase(to_delete.chunk_coord)
		to_delete.queue_free()


func _pop_gen_queue():
	var chunk_coord: Vector3i = chunk_generate_queue.pop_front()
	if not chunk_coord in active_chunks or not is_instance_valid(active_chunks[chunk_coord]):
		_generate_chunk(chunk_coord)


func _generate_chunk(chunk_coord: Vector3i):
	var space_chunk = space_chunk_scene.instantiate()
	add_child(space_chunk)
	space_chunk.chunk_coord = chunk_coord
	space_chunk.chunk_size = chunk_size
	space_chunk.generate()
	active_chunks[chunk_coord] = space_chunk
