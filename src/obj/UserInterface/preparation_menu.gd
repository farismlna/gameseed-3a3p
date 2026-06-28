extends Control

@onready var inventory_grid = $MarginContainer/HBoxContainer/RightPanelContainer/MarginContainer/VBoxContainer/RightPanel/InventoryGrid
@onready var head_slots_container = $MarginContainer/HBoxContainer/LeftPanelContainer/MarginContainer/LeftPanel/HeadSlots
@onready var hand_slots_container = $MarginContainer/HBoxContainer/LeftPanelContainer/MarginContainer/LeftPanel/HandSlots
@onready var body_slots_container = $MarginContainer/HBoxContainer/LeftPanelContainer/MarginContainer/LeftPanel/BodySlots
@onready var legs_slots_container = $MarginContainer/HBoxContainer/LeftPanelContainer/MarginContainer/LeftPanel/LegSlots

func _ready() -> void:
	name = "PreparationMenu"
	_setup_static_slots()
	_populate_equipped_slots()
	_build_ui_slots()

func _setup_static_slots() -> void:
	# Daftarkan skrip dan filter tipe target ke seluruh 4 bagian tubuh utama
	var slot_map = {
		"head": head_slots_container,
		"hand_right": hand_slots_container,
		"body": body_slots_container,
		"legs": legs_slots_container,
		# Tambahkan baris baru di sini jika ingin menambahkan slot baru, misal "hand_left": left_hand_slots_container
	}

	var slot_scene = load("res://src/obj/UserInterface/inventory_slot.tscn")

	# Loop melalui setiap kontainer slot dan tetapkan skrip InventorySlot serta target_slot_type
	for slot_type in slot_map:
		var container = slot_map[slot_type]
		if container == null:
			continue

		for child in container.get_children():
			child.queue_free()

		var slot_ui = slot_scene.instantiate() as InventorySlot
		slot_ui.target_slot_type = slot_type
		slot_ui.custom_minimum_size = Vector2(80, 80)
		slot_ui.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot_ui.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.call_deferred("add_child", slot_ui)

	# Alternatif, tapi hapus aja nanti kalo mau pake loop di atas. Ini versi manualnya:
	"""
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
	"""

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

		# Tetapkan target_slot_type agar slot UI tahu jenis trait yang bisa diterima
		slot_ui.target_slot_type = trait_data.slot
		
		slot_ui.display_trait(trait_data)

func _populate_equipped_slots() -> void:
	if head_slots_container and head_slots_container.get_child_count() > 0:
		var slot = head_slots_container.get_child(0) as InventorySlot
		if slot: slot.display_trait(TraitInventory.get_equipped("head"))
		
	if hand_slots_container and hand_slots_container.get_child_count() > 0:
		var slot = hand_slots_container.get_child(0) as InventorySlot
		if slot: slot.display_trait(TraitInventory.get_equipped("hand_right"))

	if body_slots_container and body_slots_container.get_child_count() > 0:
		var slot = body_slots_container.get_child(0) as InventorySlot
		if slot: slot.display_trait(TraitInventory.get_equipped("body"))

	if legs_slots_container and legs_slots_container.get_child_count() > 0:
		var slot = legs_slots_container.get_child(0) as InventorySlot
		if slot: slot.display_trait(TraitInventory.get_equipped("legs"))

func save_layout_to_inventory() -> void:
	# Buat mapping slot_type ke kontainer masing-masing agar mudah diakses
	var slot_map = {
		"head": head_slots_container,
		"hand_right": hand_slots_container,
		"body": body_slots_container,
		"legs": legs_slots_container,
		# tinggal tambahin satu baris aja kalo mau nambah slot baru, misal "hand_left": left_hand_slots_container
	}

	# Reset semua slot yang ada di database global sebelum menimpa dengan susunan baru
	for slot_type in slot_map:
		TraitInventory.unequip_slot(slot_type)

		var container = slot_map[slot_type]
		if container == null or container.get_child_count() == 0:
			continue

		var slot = container.get_child(0) as InventorySlot
		if slot and slot.held_trait_data:
			TraitInventory.equip_trait(slot.held_trait_data)

	# Alternatif, tapi hapus aja nanti kalo mau pake loop di atas. Ini versi manualnya:
	"""
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
	"""
