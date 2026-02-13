extends Node3D
# This file manages the creation and deletion of Chunks.


const CHUNK_MIDPOINT = Vector3(0.5, 0.5, 0.5) * Chunk.CHUNK_SIZE
const CHUNK_END_SIZE = Chunk.CHUNK_SIZE - 1

@export var render_distance = 1
var effective_render_distance = 0
enum shaders {NONE, WIREFRAME}
var shader = shaders.NONE
const WIREFRAME_2_MATERIAL = preload("uid://crpeadven7lqs")
const DIRT = preload("uid://bhs4tx3l7g7aw")


var _chunks = {}

@onready var player = $"CharacterBody3D"

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Shader Toggle"):
		if shader == shaders.NONE: #MeshInstance3D.surface_set_material():
			for ID in _chunks.keys():
				if _chunks[ID].get_child_count() > 0:
					_chunks[ID].get_child(-1).mesh.surface_set_material(0, WIREFRAME_2_MATERIAL)
			shader = shaders.WIREFRAME
			print("test")
		else:
			for ID in _chunks.keys():
				if _chunks[ID].get_child_count() > 0:
					_chunks[ID].get_child(-1).mesh.surface_set_material(0, DIRT)
			shader = shaders.NONE

func _ready() -> void:
	#var player_chunk = (player.transform.origin / Chunk.CHUNK_SIZE).round()
	for x in range(-render_distance,render_distance):
		for y in range(-render_distance,render_distance):
			for z in range(-render_distance,render_distance):
				var chunk_position = Vector3(x, y, z)
				var chunk = Chunk.new()
				chunk.chunk_position = chunk_position
				_chunks[chunk_position] = chunk
				add_child(chunk)
				#print("new chunk: ", chunk_position)


func get_block_global_position(block_global_position):
	var chunk_position = (block_global_position / Chunk.CHUNK_SIZE).floor()
	if _chunks.has(chunk_position):
		var chunk = _chunks[chunk_position]
		var sub_position = block_global_position.posmod(Chunk.CHUNK_SIZE)
		if chunk.data.has(sub_position):
			return chunk.data[sub_position]
	return 0


func set_block_global_position(block_global_position, block_id):
	var chunk_position = (block_global_position / Chunk.CHUNK_SIZE).floor()
	var chunk = _chunks[chunk_position]
	var sub_position = block_global_position.posmod(Chunk.CHUNK_SIZE)
	if block_id == 0:
		chunk.data.erase(sub_position)
	else:
		chunk.data[sub_position] = block_id
	chunk.regenerate()
