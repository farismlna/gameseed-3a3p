extends CharacterBody3D

# Variables
@export var SPEED = 2.0
@export var ROLL_SPEED = 10.0
@export var DECELERATION = 10.0
@export var JUMP_VELOCITY = 4.5
@export var ROLL_DURATION = 0.4 # How long the roll lasts (in seconds)
@export var ROLL_COOLDOWN = 0.6 # Time between dashes
@export var GLIDE_FALL_SPEED = 1.4

@onready var player_sprite: Sprite3D = $PlayerSprite
@onready var player_collision: CollisionShape3D = $PlayerCollision

var _base_speed: float
var _base_jump_velocity: float
var _base_scale: Vector3
var _active_scale: Vector3

# Roll Flags
var can_roll: bool = false
var is_rolling: bool = false
var roll_direction: Vector3 = Vector3.FORWARD
var has_roll: bool = false

# Jump State
var _jump_count: int = 0
var _max_jumps: int = 1  # Modified by traits (e.g. double jump = 2)
var _can_glide: bool = false
var _can_use_trait_action: bool = false

# LIFECYCLE
func _ready() -> void:
	_base_speed = SPEED
	_base_jump_velocity = JUMP_VELOCITY
	_base_scale = scale
	_active_scale = scale

	# Listen for trait changes to update ability parameters
	TraitInventory.trait_equipped.connect(_on_trait_equipped)
	TraitInventory.trait_unequipped.connect(_on_trait_unequipped)
	_recalculate_abilities()

# PHYSICS
func _physics_process(delta: float) -> void:
	
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
	elif _jump_count != 0:
		_jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and _jump_count < _max_jumps and JUMP_VELOCITY > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_count += 1
	elif _can_glide and not is_on_floor() and Input.is_action_pressed("Jump") and velocity.y < -GLIDE_FALL_SPEED:
		velocity.y = -GLIDE_FALL_SPEED
	
	# Handle roll.
	if Input.is_action_just_pressed("Roll") and has_roll and can_roll:
		start_roll()

	if Input.is_action_just_pressed("Ability") and _can_use_trait_action:
		_use_equipped_trait_action()

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
	scale = Vector3(_active_scale.x, _active_scale.y * 0.45, _active_scale.z)
	
	# Execute dash duration using a quick scene tree timer
	await get_tree().create_timer(ROLL_DURATION).timeout
	is_rolling = false
	scale = _active_scale
	
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
	_recalculate_abilities()
 
func _on_trait_unequipped(slot: String) -> void:
	# Recalculate all active abilities from scratch
	# This prevents stacking bugs when swapping traits
	_recalculate_abilities()
 
func _recalculate_abilities() -> void:
	# Reset to base values first
	_max_jumps = 1
	has_roll = false
	_can_glide = false
	_can_use_trait_action = false
	SPEED = _base_speed
	JUMP_VELOCITY = _base_jump_velocity
	_active_scale = _base_scale
 
	# Re-apply all currently equipped traits
	for slot in TraitInventory.equipped_slots:
		var trait_data = TraitInventory.equipped_slots[slot]
		if trait_data != null:
			_apply_trait_effect(trait_data)

	scale = _active_scale
	_update_visual_tint()

func _apply_trait_effect(trait_data: TraitData) -> void:
	match trait_data.ability_tag:
		"roll":
			has_roll = true
		"small_legs":
			SPEED *= 0.6
			JUMP_VELOCITY = 0.0
			_active_scale = Vector3(_base_scale.x * 0.75, _base_scale.y * 0.48, _base_scale.z * 0.75)
		"double_jump":
			_max_jumps = max(_max_jumps, 2)
			SPEED *= 1.1
		"frog_jump":
			JUMP_VELOCITY *= 1.45
			SPEED *= 1.12
		"glide":
			_can_glide = true
		"speed_boost":
			SPEED *= 1.5
		"sticky_tongue", "push_pull", "meow", "bark", "honk":
			_can_use_trait_action = true

func _update_visual_tint() -> void:
	if player_sprite == null:
		return

	if TraitInventory.has_ability("double_jump"):
		player_sprite.modulate = Color(1.0, 0.65, 0.35)
	elif TraitInventory.has_ability("frog_jump"):
		player_sprite.modulate = Color(0.4, 1.0, 0.45)
	elif TraitInventory.has_ability("glide"):
		player_sprite.modulate = Color(0.75, 0.95, 1.0)
	elif TraitInventory.has_ability("small_legs"):
		player_sprite.modulate = Color(1.0, 0.88, 0.55)
	else:
		player_sprite.modulate = Color.WHITE

func _use_equipped_trait_action() -> void:
	if TraitInventory.has_ability("sticky_tongue"):
		print("Sticky tongue lashes forward.")
	elif TraitInventory.has_ability("push_pull"):
		print("Hands ready: push or pull movable objects.")
	elif TraitInventory.has_ability("meow"):
		print("Meow!")
	elif TraitInventory.has_ability("bark"):
		print("Bark!")
	elif TraitInventory.has_ability("honk"):
		print("Honk!")
