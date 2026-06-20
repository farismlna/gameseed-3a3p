extends Node3D

@onready var hover_areas = $HoverAreas
@onready var carousel_pivot = $CarouselPivot

var is_holding_e: bool = false
var active_slot: String = ""

var slot_data: Dictionary = {
	"head": {"traits": [], "index": 0, "rotation": 0.0},
	"hand_right": {"traits": [], "index": 0, "rotation": 0.0},
	"body": {"traits": [], "index": 0, "rotation": 0.0},
	"legs": {"traits": [], "index": 0, "rotation": 0.0}
}

func _ready() -> void:
	carousel_pivot.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_part_menu"):
		is_holding_e = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_open_and_build_all_menus()
	elif event.is_action_released("change_part_menu"):
		is_holding_e = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_clear_and_close_menu()

	if is_holding_e and active_slot != "" and event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_rotate_active_carousel(1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_rotate_active_carousel(-1)

func _open_and_build_all_menus() -> void:
	_clear_and_close_menu()
	carousel_pivot.show()
	
	var mapping = {
		"head": "Head",
		"hand_right": "Hand",
		"body": "Body",
		"legs": "Leg"
	}
	
	for slot_key in mapping:
		var traits_list = []
		var preparation_node = get_node_or_null("/root/PreparationMenu")
		
		if preparation_node:
			# Membaca data secara dinamis dari keempat jenis kontainer panel kiri UI
			if slot_key == "head" and preparation_node.head_slots_container:
				for slot in preparation_node.head_slots_container.get_children():
					if slot is InventorySlot and slot.held_trait_data: traits_list.append(slot.held_trait_data)
			elif slot_key == "hand_right" and preparation_node.hand_slots_container:
				for slot in preparation_node.hand_slots_container.get_children():
					if slot is InventorySlot and slot.held_trait_data: traits_list.append(slot.held_trait_data)
			elif slot_key == "body" and preparation_node.body_slots_container:
				for slot in preparation_node.body_slots_container.get_children():
					if slot is InventorySlot and slot.held_trait_data: traits_list.append(slot.held_trait_data)
			elif slot_key == "legs" and preparation_node.leg_slots_container:
				for slot in preparation_node.leg_slots_container.get_children():
					if slot is InventorySlot and slot.held_trait_data: traits_list.append(slot.held_trait_data)

		slot_data[slot_key]["traits"] = traits_list
		
		var target_node = hover_areas.get_node_or_null(mapping[slot_key])
		if target_node == null: 
			continue
		
		var part_pivot = Node3D.new()
		part_pivot.name = slot_key
		part_pivot.position.y = target_node.position.y
		carousel_pivot.add_child(part_pivot)
		
		var total_items = traits_list.size()
		if total_items == 0:
			var label = Label3D.new()
			label.text = "EMPTY"
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			part_pivot.add_child(label)
		else:
			var angle_step = 360.0 / total_items
			for i in range(total_items):
				var item_node = Label3D.new()
				item_node.text = traits_list[i].display_name
				item_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				
				var rad_angle = deg_to_rad(i * angle_step)
				item_node.position = Vector3(sin(rad_angle), 0, cos(rad_angle)) * 2.0
				part_pivot.add_child(item_node)
				
		_apply_realtime_preview(slot_key)

func _rotate_active_carousel(direction: int) -> void:
	var data = slot_data[active_slot]
	var total_items = data["traits"].size()
	if total_items <= 1: 
		return
	
	var part_pivot_node = carousel_pivot.get_node_or_null(active_slot)
	if part_pivot_node == null: 
		return
	
	var angle_step = 360.0 / total_items
	data["rotation"] -= direction * angle_step
	data["index"] = (data["index"] + direction) % total_items
	
	if data["index"] < 0:
		data["index"] += total_items
		
	var tween = create_tween()
	tween.tween_property(part_pivot_node, "rotation_degrees:y", data["rotation"], 0.15)
	
	_apply_realtime_preview(active_slot)

func _apply_realtime_preview(slot_key: String) -> void:
	var data = slot_data[slot_key]
	if data["traits"].size() > 0:
		var trait_id = data["traits"][data["index"]].id
		var parent_player = get_parent()
		if parent_player and parent_player.has_method("ubah_organ_tubuh"):
			parent_player.ubah_organ_tubuh(slot_key, trait_id)

func _clear_and_close_menu() -> void:
	active_slot = ""
	carousel_pivot.hide()
	for child in carousel_pivot.get_children():
		child.queue_free()

func _on_head_mouse_entered() -> void:
	active_slot = "head"

func _on_hand_mouse_entered() -> void:
	active_slot = "hand_right"

func _on_body_mouse_entered() -> void:
	active_slot = "body"

func _on_leg_mouse_entered() -> void:
	active_slot = "legs"

func _on_part_mouse_exited() -> void:
	active_slot = ""
