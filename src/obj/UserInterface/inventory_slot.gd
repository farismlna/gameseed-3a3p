extends TextureRect
class_name InventorySlot

var held_trait_data: TraitData = null
var target_slot_type: String = "" # Diisi "head", "hand_right", dll. Jika di panel kiri

func display_trait(trait_data: TraitData) -> void:
	held_trait_data = trait_data
	if trait_data and trait_data.icon:
		texture = trait_data.icon
	else:
		# Gunakan placeholder gambar kompor dari Farris jika icon resource kosong
		texture = load("res://src/obj/interactable/stove.png")

func clear_slot() -> void:
	held_trait_data = null
	texture = null

# --- GODOT BUILT-IN DRAG AND DROP SYSTEM ---

func _get_drag_data(at_position: Vector2) -> Variant:
	if held_trait_data == null:
		return null
		
	# Membuat preview visual saat item melayang ditarik mouse
	var preview = TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(64, 64)
	set_drag_preview(preview)
	
	# Mengirim data slot ini ke sistem drag Godot
	return self

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is InventorySlot:
		# Jika slot ini berada di panel kiri (slot tubuh), cek apakah jenis part-nya cocok
		if target_slot_type != "" and data.held_trait_data.slot != target_slot_type:
			return false
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var source_slot = data as InventorySlot
	var temp_trait = held_trait_data
	
	# Tukar data trait antar kedua slot
	display_trait(source_slot.held_trait_data)
	
	if temp_trait:
		source_slot.display_trait(temp_trait)
	else:
		source_slot.clear_slot()
		
	# Beritahu menu utama untuk menyimpan susunan terbaru ke database global
	var menu = get_tree().current_scene.get_node_or_null("PreparationMenu")
	if menu:
		menu.save_layout_to_inventory()
