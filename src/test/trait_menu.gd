extends Node3D

@onready var hover_areas = $HoverAreas
@onready var carousel_pivot = $CarouselPivot

var is_holding_e: bool = false
var active_slot: String = ""
var current_traits: Array = []
var current_trait_index: int = 0
var target_rotation_y: float = 0.0
var ring_tween : Tween

func _ready() -> void:
	carousel_pivot.hide()
	
	# Sembunyikan Sprite3D lingkaran 2D di awal permainan
	for area in hover_areas.get_children():
		var ring = area.get_node_or_null("AnimRing") as Sprite3D
		if ring:
			ring.hide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_part_menu"):
		is_holding_e = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_circle_animation()
	elif event.is_action_released("change_part_menu"):
		is_holding_e = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_close_menu()

	if is_holding_e and active_slot != "" and event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_putar_carousel(1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_putar_carousel(-1)

func _circle_animation():
	if ring_tween and ring_tween.is_valid():
		ring_tween.kill()
	ring_tween = create_tween().set_loops().set_parallel(true)
	for area in hover_areas.get_children():
		var ring = area.get_node_or_null("AnimRing") as Sprite3D
		if ring == null:
			continue 
			
		ring.show()

		
		var tween = create_tween().set_loops()
		tween.tween_property(ring, "scale", Vector3(0.2, 0.2, 0.2), 1.0).from(Vector3(0.05,0.05,0.05))
		# Gunakan modulate:a untuk membuat Sprite3D memudar perlahan
		tween.parallel().tween_property(ring, "modulate:a", 0.0, 1.0).from(0.5)

func _close_menu():
	if ring_tween and ring_tween.is_valid():
		ring_tween.kill()
		
	for area in hover_areas.get_children():
		var ring = area.get_node_or_null("AnimRing")
		if ring:
			ring.hide() 
	
	for child in carousel_pivot.get_children():
		child.queue_free()
		
	active_slot = ""
	carousel_pivot.hide()

func _putar_carousel(arah: int):
	var total_items = current_traits.size()
	if total_items <= 1:
		return
		
	var angle_step = 360.0 / total_items
	target_rotation_y -= arah * angle_step
	current_trait_index = (current_trait_index + arah) % total_items
	
	if current_trait_index < 0:
		current_trait_index += total_items
		
	var tween = create_tween()
	tween.tween_property(carousel_pivot, "rotation_degrees:y", target_rotation_y, 0.15)
	
	_realtime_preview()

func _build_carousel(slot_name: String):
	for child in carousel_pivot.get_children():
		child.queue_free()
		
	carousel_pivot.rotation_degrees.y = 0
	target_rotation_y = 0.0
	current_trait_index = 0
	
	current_traits = TraitInventory.get_collected_for_slot(slot_name)
	var total_items = current_traits.size()
	
	if total_items == 0:
		var label = Label3D.new()
		label.text = "KOSONG"
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		carousel_pivot.add_child(label)
	else:
		var angle_step = 360.0 / total_items
		for i in range(total_items):
			var item_node = Label3D.new()
			item_node.text = current_traits[i].display_name
			item_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			
			var rad_angle = deg_to_rad(i * angle_step)
			item_node.position = Vector3(sin(rad_angle), 0, cos(rad_angle)) * 2.0
			carousel_pivot.add_child(item_node)
			
	carousel_pivot.position.y = hover_areas.get_node(slot_name.replace("_right", "")).position.y
	carousel_pivot.show()
	
	if total_items > 0:
		_realtime_preview()

func _realtime_preview():
	if current_traits.size() > 0:
		var trait_id = current_traits[current_trait_index].id
		var parent_player = get_parent()
		if parent_player.has_method("ubah_organ_tubuh"):
			parent_player.ubah_organ_tubuh(active_slot, trait_id)

func _on_head_mouse_entered() -> void:
	_trigger_hover("Head")


func _on_head_mouse_exited() -> void:
	pass


func _on_hand_mouse_entered() -> void:
	_trigger_hover("Hand")


func _on_hand_mouse_exited() -> void:
	pass # Replace with function body.


func _on_body_mouse_entered() -> void:
	_trigger_hover("Body")


func _on_body_mouse_exited() -> void:
	pass # Replace with function body.


func _on_leg_mouse_entered() -> void:
	_trigger_hover("Leg")


func _on_leg_mouse_exited() -> void:
	pass # Replace with function body.
	
func _trigger_hover(slot_name: String):
	if is_holding_e and active_slot != slot_name:
		active_slot = slot_name
		_build_carousel(slot_name)
