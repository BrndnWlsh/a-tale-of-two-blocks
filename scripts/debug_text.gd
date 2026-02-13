extends Label
@onready var player: CharacterBody3D = $"../CharacterBody3D"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player_pos = player.transform.origin
	text = " FPS: %s\nx: %s\ny: %s\nz: %s" % [Engine.get_frames_per_second(), int(player_pos.x), int(player_pos.y), int(player_pos.z)]
