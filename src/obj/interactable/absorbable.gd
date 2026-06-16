class_name Absorbable
extends Node3D

#  Absorbable - attach to any Animal/Object node
#  that the player can absorb traits from
#
#  Setup per object:
#  1. Attach this script to your animal/object Node3D
#  2. Add an Area3D child named "AbsorbArea" with a CollisionShape3D
#  3. Assign traits in the inspector via `source_traits`

## All traits this object/animal provides when absorbed
@export var source_traits: Array[TraitData] = []

## Label shown above the object (e.g. "Frog", "Stove")
@export var display_name: String = "Unknown"

## Whether this object disappears after being fully absorbed
@export var despawn_on_absorb: bool = false

## Prompt UI node to assign a Label3D or your prompt scene here
@onready var prompt_label: Label3D = $PromptLabel

## Internal state
var _player_in_range: bool = false
var _player_ref: CharacterBody3D = null

# LIFECYCLE
func _ready() -> void:
	# Connect Area3D signals, requires child node named "AbsorbArea"
	var area = get_node_or_null("AbsorbArea")
	if area == null:
		push_error("Absorbable on '%s': Missing child Area3D named 'AbsorbArea'." % name)
		return

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	_set_prompt_visible(false)

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return

	if Input.is_action_just_pressed("Absorb"):
		_trigger_absorption()

# ABSORPTION LOGIC
func _trigger_absorption() -> void:
	if source_traits.is_empty():
		push_warning("Absorbable '%s': No traits defined." % display_name)
		return

	var newly_absorbed = TraitInventory.absorb_from(source_traits)

	# DEBUG (DELETE WHEN IT DONE)
	print("Collected traits: ", TraitInventory.collected_traits.keys())

	if newly_absorbed.is_empty():
		# Player already has all traits from this source
		_show_feedback("Already absorbed!")
		return

	_show_feedback("Absorbed %s!" % display_name)

	if despawn_on_absorb:
		_set_prompt_visible(false)
		queue_free()


#  AREA DETECTION
func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_ref = body
		_player_in_range = true
		_set_prompt_visible(true)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_ref = null
		_player_in_range = false
		_set_prompt_visible(false)


#  UI HELPERS
func _set_prompt_visible(visible: bool) -> void:
	if prompt_label:
		prompt_label.visible = visible
		if visible:
			prompt_label.text = "Press [F] to absorb %s" % display_name

func _show_feedback(message: String) -> void:
	if prompt_label:
		prompt_label.text = message
	# Optionally hide after a short delay
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(self):
		_set_prompt_visible(_player_in_range)
