extends CharacterBody3D

# Variables
@export var SPEED = 2.0
@export var ROLL_SPEED = 10.0
@export var DECELERATION = 10.0
@export var JUMP_VELOCITY = 4.5
@export var ROLL_DURATION = 0.4 # How long the roll lasts (in seconds)
@export var ROLL_COOLDOWN = 0.6 # Time between dashes
@export var MAX_SAFE_FALL_DISTANCE: float = 8.0 # Jarak jatuh maksimal (dalam meter) sebelum mati instan

var _highest_y: float = 0.0
var _was_in_air: bool = false
var _negate_fall_damage: bool = false # Diaktifkan oleh trait kaki kucing

# Roll Flags
var can_roll: bool = false
var is_rolling: bool = false
var roll_direction: Vector3 = Vector3.FORWARD

# Jump State
var _jump_count: int = 0
var _max_jumps: int = 1  # Modified by traits (e.g. double jump = 2)

# Menu UI
var active_preparation_menu: Control = null
var is_inventory_open: bool = false

# LIFECYCLE
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	active_preparation_menu = preload("res://src/obj/UserInterface/preparation_menu.tscn").instantiate() as Control
	active_preparation_menu.hide()
	get_tree().root.call_deferred("add_child", active_preparation_menu)
	
	# Listen for trait changes to update ability parameters
	TraitInventory.trait_equipped.connect(_on_trait_equipped)
	TraitInventory.trait_unequipped.connect(_on_trait_unequipped)

# PHYSICS
func _physics_process(delta: float) -> void:
	if is_inventory_open:
		velocity = Vector3.ZERO # Paksa player diam di tempat
		move_and_slide()
		return
	
	# Roll action.
	if is_rolling:
		# Force velocity purely in the dash direction across X and Z
		velocity.x = roll_direction.x * ROLL_SPEED
		velocity.z = roll_direction.z * ROLL_SPEED
		velocity.y = 0 # Optional: Freeze vertical movement during dash
		move_and_slide()
		return # Bypass standard physics and movement inputs
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

		# Jika baru pertama kali lepas dari lantai, catat tinggi awal Y
		if not _was_in_air:
			_highest_y = global_position.y
			_was_in_air = true
		else:
			# Update terus jika pemain ternyata melompat lebih tinggi dari titik awal
			if global_position.y > _highest_y:
				_highest_y = global_position.y
	else:
		_jump_count = 0 
		if _was_in_air:
			var fall_distance = _highest_y - global_position.y
			
			# EKSEKUSI MATI: Jika jarak melebihi threshold DAN tidak punya efek anti-fall damage
			if fall_distance > MAX_SAFE_FALL_DISTANCE and not _negate_fall_damage:
				_die()
				
			_was_in_air = false

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and _jump_count < _max_jumps:
		velocity.y = JUMP_VELOCITY
		_jump_count += 1
	
	# Handle roll.
	if Input.is_action_just_pressed("Roll") and can_roll:
		start_roll()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		roll_direction = direction
		can_roll = true
	else:
		var target_velocity_x = direction.x * SPEED
		var target_velocity_z = direction.z * SPEED
		velocity.x = move_toward(velocity.x, target_velocity_x, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity_z, DECELERATION * delta)
		can_roll = false

	move_and_slide()
	
	
func start_roll():
	is_rolling = true
	can_roll = false
	
	# Execute dash duration using a quick scene tree timer
	await get_tree().create_timer(ROLL_DURATION).timeout
	is_rolling = false
	
	# Execute cooldown before allowing another dash
	await get_tree().create_timer(ROLL_COOLDOWN).timeout
	can_roll = true


#  TRAIT INTEGRATION
## Equip a trait into a slot by id.
## Called from change_part_menu when player selects a trait.
func ubah_organ_tubuh(slot: String, trait_id: String) -> void:
	var trait_data: TraitData = TraitInventory.collected_traits.get(trait_id, null)
 
	if trait_data == null:
		push_warning("Player: Trait '%s' not found in inventory." % trait_id)
		return
 
	var success = TraitInventory.equip_trait(trait_data)
	if not success:
		# Capacity exceeded, UI should handle showing feedback to player
		push_warning("Player: Not enough capacity to equip '%s'." % trait_id)
 
## Unequip trait from a slot.
func lepas_organ_tubuh(slot: String) -> void:
	TraitInventory.unequip_slot(slot)
 

#  TRAIT ABILITY HOOKS
#  Add ability effects here as traits are implemented
func _on_trait_equipped(slot: String, trait_data: TraitData) -> void:
	match trait_data.ability_tag:
		"double_jump":
			_max_jumps = 2
		"speed_boost":
			SPEED *= 1.5
		"cat_legs":
			_negate_fall_damage = true
		# Add more ability_tags here as new traits are created
 
func _on_trait_unequipped(slot: String) -> void:
	# Recalculate all active abilities from scratch
	# This prevents stacking bugs when swapping traits
	_recalculate_abilities()
 
func _recalculate_abilities() -> void:
	# Reset to base values first
	_max_jumps = 1
	SPEED = 2.0
	_negate_fall_damage = false
	# Re-apply all currently equipped traits
	for slot in TraitInventory.equipped_slots:
		var trait_data = TraitInventory.equipped_slots[slot]
		if trait_data != null:
			_on_trait_equipped(slot, trait_data)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if not is_inventory_open:
			is_inventory_open = true
			active_preparation_menu._build_ui_slots()  # refresh isi sebelum tampil
			active_preparation_menu.show()
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			is_inventory_open = false
			active_preparation_menu.hide()
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _die() -> void:
	# Handle player death (e.g., respawn, game over, etc.)
	print("Player has died due to fall damage.")
	# For now, just reset position to a safe point (this should be replaced with proper death handling)
	global_position = Vector3(0, 5, 0)  # Example respawn position
	velocity = Vector3.ZERO