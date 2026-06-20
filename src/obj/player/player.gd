extends CharacterBody3D

# Variables
@export var SPEED = 2.0
@export var ROLL_SPEED = 10.0
@export var DECELERATION = 10.0
@export var JUMP_VELOCITY = 4.5
@export var ROLL_DURATION = 0.4 # How long the roll lasts (in seconds)
@export var ROLL_COOLDOWN = 0.6 # Time between dashes

# Roll Flags
var can_roll: bool = false
var is_rolling: bool = false
var roll_direction: Vector3 = Vector3.FORWARD

# Jump State
var _jump_count: int = 0
var _max_jumps: int = 1  # Modified by traits (e.g. double jump = 2)

# Menu UI
var preparation_menu_scene = preload("res://src/obj/UserInterface/preparation_menu.tscn")
var active_preparation_menu: Control = null
var is_inventory_open: bool = false

# LIFECYCLE
func _ready() -> void:
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

	# Handle jump.
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
		# Add more ability_tags here as new traits are created
 
func _on_trait_unequipped(slot: String) -> void:
	# Recalculate all active abilities from scratch
	# This prevents stacking bugs when swapping traits
	_recalculate_abilities()
 
func _recalculate_abilities() -> void:
	# Reset to base values first
	_max_jumps = 1
	SPEED = 2.0
 
	# Re-apply all currently equipped traits
	for slot in TraitInventory.equipped_slots:
		var trait_data = TraitInventory.equipped_slots[slot]
		if trait_data != null:
			_on_trait_equipped(slot, trait_data)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if active_preparation_menu == null:
			is_inventory_open = true
			active_preparation_menu = preparation_menu_scene.instantiate() as Control
			get_tree().root.add_child(active_preparation_menu)
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			active_preparation_menu.queue_free()
			active_preparation_menu = null
			get_tree().paused = false
			is_inventory_open = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
