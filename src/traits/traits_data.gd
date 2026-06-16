class_name TraitData
extends Resource

#  TraitData - defines a single trait's identity
#  creat with .tres file in the editor

## Unique identifier for this trait (e.g. "frog_legs", "cat_body")
@export var id: String = ""

## Display name shown in UI (e.g. "Frog Legs")
@export var display_name: String = ""

## Which body part slot this trait occupies
## Valid values: "head", "body", "hand_right", "hand_left", "legs"
@export var slot: String = ""

## Equip cost
@export var equip_cost: int = 1

## Description shown in catalogue/inventory UI
@export var description: String = ""

## Icon shown in UI (assign a Texture2D in the editor)
@export var icon: Texture2D = null

## Scene to instance as a visual overlay on the player when equipped
## Leave null if no visual transformation is needed
@export var visual_scene: PackedScene = null

## Ability tag is used by other systems to check what the player can do
## Examples: "double_jump", "wall_stick", "underwater", "glide"
@export var ability_tag: String = ""
