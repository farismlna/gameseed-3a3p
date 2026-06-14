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

# Keeps track of the 3D vector direction the player is moving/facing
var roll_direction: Vector3 = Vector3.FORWARD

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
