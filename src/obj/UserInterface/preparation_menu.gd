extends Control

@onready var inventory_grid = $HBoxContainer/RightPanel/InventoryGrid
@onready var head_slots_container = $HBoxContainer/LeftPanel/HeadSlots
@onready var hand_slots_container = $HBoxContainer/LeftPanel/HandSlots

func _ready() -> void:
	name = "PreparationMenu"
	_build_ui_slots()

func _build_ui_slots() -> void:
	# 1. Bersihkan sisa UI lama
	for child in inventory_grid.get_children(): child.queue_free()
	
	# 2. Ambil semua traits yang dikumpulkan dari Autoload milik Farris
	var all_collected = TraitInventory.collected_traits.values()
	
	# 3. Buat item di grid kanan sesuai isi koleksi yang sudah di-absorb
	for trait_data in all_collected:
		var slot_ui = TextureRect.new()
		slot_ui.set_script(load("res://src/obj/UserInterface/inventory_slot.gd"))
		inventory_grid.add_child(slot_ui)
		slot_ui.display_trait(trait_data)
		
	# 4. Setup properti filter untuk 3 kotak slot di bagian Head (Panel Kiri)
	for slot_node in head_slots_container.get_children():
		if slot_node is TextureRect:
			slot_node.set_script(load("res://src/obj/UserInterface/inventory_slot.gd"))
			slot_node.target_slot_type = "head"
			
	# 5. Setup properti filter untuk 3 kotak slot di bagian Hand (Panel Kiri)
	for slot_node in hand_slots_container.get_children():
		if slot_node is TextureRect:
			slot_node.set_script(load("res://src/obj/UserInterface/inventory_slot.gd"))
			slot_node.target_slot_type = "hand_right"

func save_layout_to_inventory() -> void:
	# Kosongkan pilihan lama di database Farris terlebih dahulu sebelum menimpa susunan baru
	TraitInventory.equipped_slots["head"] = null
	TraitInventory.equipped_slots["hand_right"] = null
	
	# Ambil slot terpasang pertama dari panel kiri untuk didaftarkan sebagai yang aktif bertransformasi
	var first_head_slot = head_slots_container.get_child(0) as InventorySlot
	if first_head_slot and first_head_slot.held_trait_data:
		TraitInventory.equip_trait(first_head_slot.held_trait_data)
		
	var first_hand_slot = hand_slots_container.get_child(0) as InventorySlot
	if first_hand_slot and first_hand_slot.held_trait_data:
		TraitInventory.equip_trait(first_hand_slot.held_trait_data)
