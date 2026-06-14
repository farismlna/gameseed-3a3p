extends Camera3D

@export var player: Node3D # Drag your player node here in the inspector
@export var follow_speed: float = 5.0
@export var offset_vector: Vector3 = Vector3(0, 5, -10) # Relative distance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		global_position = global_position.lerp(player.global_position + offset_vector, follow_speed * delta)
