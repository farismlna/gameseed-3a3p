class_name TraitGate
extends StaticBody3D

@export var required_abilities: PackedStringArray = PackedStringArray()
@export var display_name: String = "Gate"
@export_multiline var success_text: String = "Unlocked."
@export_multiline var failure_text: String = "Missing trait."
@export var disappear_on_unlock: bool = true

@onready var prompt_label: Label3D = get_node_or_null("PromptLabel")
@onready var gate_area: Area3D = get_node_or_null("GateArea")
@onready var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D")

var _player_in_range: bool = false
var _unlocked: bool = false

func _ready() -> void:
	if gate_area == null:
		push_error("TraitGate on '%s': Missing child Area3D named 'GateArea'." % name)
		return

	gate_area.body_entered.connect(_on_body_entered)
	gate_area.body_exited.connect(_on_body_exited)
	TraitInventory.inventory_changed.connect(_refresh_prompt)
	_refresh_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("Absorb"):
		_try_unlock()

func _try_unlock() -> void:
	if _unlocked:
		return

	if TraitInventory.has_all_abilities(required_abilities):
		_unlocked = true
		_show_message(success_text)
		if collision_shape != null:
			collision_shape.disabled = true
		if disappear_on_unlock:
			await get_tree().create_timer(0.45).timeout
			if is_instance_valid(self):
				queue_free()
	else:
		var missing = TraitInventory.get_missing_abilities(required_abilities)
		if missing.is_empty():
			_show_message(failure_text)
		else:
			_show_message("%s: %s" % [failure_text, _join_abilities(missing)])

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_in_range = true
		_refresh_prompt()

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_in_range = false
		_refresh_prompt()

func _refresh_prompt() -> void:
	if prompt_label == null:
		return

	prompt_label.visible = _player_in_range
	if not _player_in_range:
		return

	if TraitInventory.has_all_abilities(required_abilities):
		prompt_label.text = "Press [F] to open %s" % display_name
	else:
		prompt_label.text = "%s needs: %s" % [display_name, _join_abilities(required_abilities)]

func _show_message(message: String) -> void:
	if prompt_label != null:
		prompt_label.visible = true
		prompt_label.text = message

func _join_abilities(abilities: PackedStringArray) -> String:
	var result = ""
	for ability_index in range(abilities.size()):
		if ability_index > 0:
			result += ", "
		result += _format_ability(abilities[ability_index])
	return result

func _format_ability(ability_tag: String) -> String:
	return ability_tag.replace("_", " ").capitalize()
