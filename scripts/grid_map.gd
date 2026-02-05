extends GridMap
const WIREFRAME_2 = preload("uid://kdivrvr4eyav")
const WIREFRAME_2_MATERIAL = preload("uid://crpeadven7lqs")
const MESH_LIBRARY = preload("uid://drjxm425sub0f")
const DIRT = preload("uid://bhs4tx3l7g7aw")
const STONE = preload("uid://dglwque2snpsl")
enum shaders {NONE, WIREFRAME}
var shader = shaders.NONE
const materials = {0:DIRT, 1:STONE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_chunk(Vector3i(0,0,0))
	generate_chunk(Vector3i(-1,0,0))
	generate_chunk(Vector3i(0,0,-1))
	generate_chunk(Vector3i(-1,0,-1))
	cull_faces(Vector3i(0,0,0))
	

func generate_chunk(region_coords: Vector3i):
	for x in range(16 * region_coords.x,16 * region_coords.x + 16):
		for y in range (16 * region_coords.y - 16, 16 * region_coords.y):
			for z in range(16 * region_coords.z, 16 * region_coords.z + 16):
				#var block = mesh_library.get_item_mesh(0)
				set_cell_item(Vector3i(x, y, z), 1)

func cull_faces(region_coords: Vector3i):
	for x in range(region_coords.x,region_coords.x + 16):
		for y in range (region_coords.y-16, region_coords.y):
			for z in range(region_coords.z, region_coords.z + 16):
				get_cell_item(Vector3i(x, y, z))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("Shader Toggle"):
		if shader == shaders.NONE:
			for ID in MESH_LIBRARY.get_item_list():
				MESH_LIBRARY.get_item_mesh(ID).surface_set_material(0, WIREFRAME_2_MATERIAL)
			shader = shaders.WIREFRAME
			await get_tree().create_timer(1).timeout
		else:
			for ID in MESH_LIBRARY.get_item_list():
				MESH_LIBRARY.get_item_mesh(ID).surface_set_material(0, materials[ID])
			shader = shaders.NONE
			await get_tree().create_timer(1).timeout
			
