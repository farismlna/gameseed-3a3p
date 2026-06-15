extends Node

#  TraitInventory - Autoload (Singleton)
#  Manages all collected traits and equipped slots
#
#  Setup: Project → Project Settings → Autoload
#         Path : res://src/traits/trait_inventory.gd
#         Name : TraitInventory

## Maximum total equip cost the player can have active at once (dummy)
const MAX_EQUIP_CAPACITY: int = 10

## Key: trait id (String), Value: TraitData
var collected_traits: Dictionary = {}

## Key: slot name (String), Value: TraitData or null
var equipped_slots: Dictionary = {
	"head":       null,
	"body":       null,
	"hand_right": null,
	"hand_left":  null,
	"legs":       null,
}

## Emitted when a new trait is absorbed into the inventory
signal trait_absorbed(trait_data: TraitData)

## Emitted when a trait is equipped into a slot
signal trait_equipped(slot: String, trait_data: TraitData)

## Emitted when a trait is unequipped from a slot
signal trait_unequipped(slot: String)

## Called when player absorbs an absorbable object.
## Adds all traits from that object to collected_traits.
## Returns list of newly absorbed TraitData (excludes duplicates).
func absorb_from(source_traits: Array[TraitData]) -> Array[TraitData]:
	var newly_absorbed: Array[TraitData] = []

	for trait_data in source_traits:
		if trait_data.id == "":
			push_warning("TraitInventory: Skipping trait with empty id.")
			continue

		if not collected_traits.has(trait_data.id):
			collected_traits[trait_data.id] = trait_data
			newly_absorbed.append(trait_data)
			trait_absorbed.emit(trait_data)

	return newly_absorbed

## Returns current total equip cost of all equipped traits
func get_current_capacity_used() -> int:
	var total: int = 0
	for slot in equipped_slots:
		if equipped_slots[slot] != null:
			total += equipped_slots[slot].equip_cost
	return total

## Returns true if equipping this trait would exceed MAX_EQUIP_CAPACITY
func would_exceed_capacity(trait_data: TraitData) -> bool:
	var current_slot_occupant = equipped_slots.get(trait_data.slot, null)
	var freed_cost: int = current_slot_occupant.equip_cost if current_slot_occupant != null else 0
	return (get_current_capacity_used() - freed_cost + trait_data.equip_cost) > MAX_EQUIP_CAPACITY

## Equip a trait into its designated slot.
## Returns false if capacity would be exceeded.
func equip_trait(trait_data: TraitData) -> bool:
	if not equipped_slots.has(trait_data.slot):
		push_warning("TraitInventory: Unknown slot '%s'." % trait_data.slot)
		return false

	if would_exceed_capacity(trait_data):
		return false

	equipped_slots[trait_data.slot] = trait_data
	trait_equipped.emit(trait_data.slot, trait_data)
	return true

## Unequip whatever is in the given slot.
func unequip_slot(slot: String) -> void:
	if not equipped_slots.has(slot):
		push_warning("TraitInventory: Unknown slot '%s'." % slot)
		return

	equipped_slots[slot] = null
	trait_unequipped.emit(slot)

## Returns true if player currently has a specific ability active
## Use this in movement/puzzle scripts to check trait abilities
## Example: TraitInventory.has_ability("double_jump")
func has_ability(ability_tag: String) -> bool:
	for slot in equipped_slots:
		var trait_data = equipped_slots[slot]
		if trait_data != null and trait_data.ability_tag == ability_tag:
			return true
	return false

## Returns all collected traits that belong to a specific slot
func get_collected_for_slot(slot: String) -> Array[TraitData]:
	var result: Array[TraitData] = []
	for id in collected_traits:
		if collected_traits[id].slot == slot:
			result.append(collected_traits[id])
	return result

## Returns the currently equipped trait for a slot, or null
func get_equipped(slot: String) -> TraitData:
	return equipped_slots.get(slot, null)
