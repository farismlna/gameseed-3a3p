extends Control

@onready var inventory_grid = $HBoxContainer/RightPanel/InventoryGrid
@onready var head_slots_container = $HBoxContainer/LeftPanel/HeadSlots
@onready var hand_slots_container = $HBoxContainer/LeftPanel/HandSlots
@onready var body_slots_container = $HBoxContainer/LeftPanel/BodySlots
@onready var legs_slots_container = $HBoxContainer/LeftPanel/LegSlots # ◄── Diubah menjadi LegSlots agar tidak eror lagi

func _ready() -> void:
	name = "PreparationMenu"
	_setup_static_slots()
	_build_ui_slots()

func _setup_static_slots() -> void:
	# Daftarkan skrip dan filter tipe target ke seluruh 4 bagian tubuh utama
	if head_slots_container:
		for slot in head_slots_container.get_children():
			if slot is TextureRect:
				slot.set_script(load("res://src/obj/UserInterface/inventory_slot.gd"))
				slot.target_slot_type = "head"
			
	if hand_slots_container:
		for slot in hand_slots_container.get_children():
			if slot is TextureRect:
				slot.set_script(load("res://src/obj/UserInterface/inventory_slot.gd"))
				slot.target_slot_type = "hand_right"

	if body_slots_container:
		for slot in body_slots_container.get_children():
			if slot is TextureRect:
				slot.set_script(load("res://src/obj/UserInterface/inventory_slot.gd"))
				slot.target_slot_type = "body"

	if legs_slots_container:
		for slot in legs_slots_container.get_children():
			if slot is TextureRect:
				slot.set_script(load("res://src/obj/UserInterface/inventory_slot.gd"))
				slot.target_slot_type = "legs"

func _build_ui_slots() -> void:
	if inventory_grid == null:
		return
		
	for child in inventory_grid.get_children():
		child.queue_free()
		
	var all_collected = TraitInventory.collected_traits.values()
	var slot_scene = load("res://src/obj/UserInterface/inventory_slot.tscn")
	
	for trait_data in all_collected:
		var slot_ui = slot_scene.instantiate() as InventorySlot
		inventory_grid.add_child(slot_ui)
		
		# Paksa ukuran visual gambar agar pasti muncul dan tidak 0x0 pixel
		slot_ui.custom_minimum_size = Vector2(100, 100)
		slot_ui.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot_ui.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		slot_ui.display_trait(trait_data)

func save_layout_to_inventory() -> void:
	# Reset status lama di database global sebelum menimpa susunan baru
	TraitInventory.equipped_slots["head"] = null
	TraitInventory.equipped_slots["hand_right"] = null
	TraitInventory.equipped_slots["body"] = null
	TraitInventory.equipped_slots["legs"] = null
	
	# Simpan data dari keempat kontainer UI kiri ke database global
	if head_slots_container and head_slots_container.get_child_count() > 0:
		var slot = head_slots_container.get_child(0) as InventorySlot
		if slot and slot.held_trait_data: TraitInventory.equip_trait(slot.held_trait_data)
		
	if hand_slots_container and hand_slots_container.get_child_count() > 0:
		var slot = hand_slots_container.get_child(0) as InventorySlot
		if slot and slot.held_trait_data: TraitInventory.equip_trait(slot.held_trait_data)

	if body_slots_container and body_slots_container.get_child_count() > 0:
		var slot = body_slots_container.get_child(0) as InventorySlot
		if slot and slot.held_trait_data: TraitInventory.equip_trait(slot.held_trait_data)

	if legs_slots_container and legs_slots_container.get_child_count() > 0:
		var slot = legs_slots_container.get_child(0) as InventorySlot
		if slot and slot.held_trait_data: TraitInventory.equip_trait(slot.held_trait_data)