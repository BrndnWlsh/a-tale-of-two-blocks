extends ItemList
const MESH_LIBRARY = preload("uid://drjxm425sub0f")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for index in range(9):
		if index in MESH_LIBRARY.get_item_list():
			add_item(MESH_LIBRARY.get_item_name(index), MESH_LIBRARY.get_item_preview(index))
		else:
			add_item(str(index + 1))
	select(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
