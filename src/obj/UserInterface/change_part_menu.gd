extends Node2D

# Referensi ke Node UI menggunakan path sesuai gambar Anda
@onready var ui_container = $Control
@onready var sub_menu = $Control/HBoxContainer/SubMain
@onready var main_menu = $Control/HBoxContainer/Main

# Mengambil referensi Node Player dan Kamera di ruang 3D secara absolut
@onready var player = get_node_or_null("../Player")
@onready var camera = get_node_or_null("../PlayerCam")

# Atur jarak melayang UI di seblah kanan Player (dalam satuan pixel)
@export var ui_offset: Vector2 = Vector2(120,-6)

# Variabel untuk mencatat slot apa yang sedang dipilih oleh pemain
var current_selected_slot: String = ""
var _visible_traits: Array[TraitData] = []

func _ready():
	# 1. Sembunyikan seluruh UI dan SubMain saat game dimulai
	ui_container.hide()
	sub_menu.hide()
	
	# 2. Hubungkan sinyal tombol menu utama ke fungsi logikanya
	$Control/HBoxContainer/Main/BtnHead.pressed.connect(func(): _on_slot_clicked("head"))
	$Control/HBoxContainer/Main/BtnHand.pressed.connect(func(): _on_slot_clicked("hand_right"))
	$Control/HBoxContainer/Main/BtnLeg.pressed.connect(func(): _on_slot_clicked("legs"))
	$Control/HBoxContainer/Main/BtnBody.pressed.connect(func(): _on_slot_clicked("body"))

	$Control/HBoxContainer/Main/BtnHand.text = "R Hand"
	_add_left_hand_button()
	TraitInventory.inventory_changed.connect(_refresh_submenu)
	_refresh_submenu()

func _unhandled_input(event):
	# Fitur Buka/Tutup Menu dengan tombol "E"
	if event.is_action_pressed("change_part_menu"): # Pastikan "E" sudah didaftarkan di Input Map dengan nama ini
		if ui_container.visible:
			ui_container.hide()
			sub_menu.hide() # Ikut sembunyikan sub-menu saat UI ditutup
		else:
			ui_container.show()

func _process(delta: float) -> void:
	if ui_container.visible and player and camera:
		var player_3d_position: Vector3 = player.global_position

		if camera.is_position_behind(player_3d_position):
			hide()
			return
		else:
			show()
		var screen_position: Vector2 = camera.unproject_position(player_3d_position)

		global_position = screen_position + ui_offset


# Fungsi saat tombol Head/Hand/Leg/Body ditekan
func _on_slot_clicked(slot_name: String):
	current_selected_slot = slot_name
	_refresh_submenu()
	sub_menu.show()

func _add_left_hand_button() -> void:
	if main_menu.get_node_or_null("BtnLeftHand") != null:
		return

	var left_hand_button = Button.new()
	left_hand_button.name = "BtnLeftHand"
	left_hand_button.text = "L Hand"
	left_hand_button.pressed.connect(func(): _on_slot_clicked("hand_left"))
	main_menu.add_child(left_hand_button)

func _refresh_submenu() -> void:
	for child in sub_menu.get_children():
		sub_menu.remove_child(child)
		child.queue_free()

	if current_selected_slot == "":
		return

	_visible_traits = TraitInventory.get_collected_for_slot(current_selected_slot)
	if _visible_traits.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No traits yet"
		sub_menu.add_child(empty_label)
	else:
		for trait_data in _visible_traits:
			var trait_button = Button.new()
			var trait_id = trait_data.id
			trait_button.text = _format_trait_button_text(trait_data)
			trait_button.pressed.connect(func(): _on_trait_clicked(trait_id))
			sub_menu.add_child(trait_button)

	var equipped_trait = TraitInventory.get_equipped(current_selected_slot)
	if equipped_trait != null:
		var unequip_button = Button.new()
		unequip_button.text = "Unequip %s" % equipped_trait.display_name
		unequip_button.pressed.connect(func(): _on_unequip_clicked())
		sub_menu.add_child(unequip_button)

func _format_trait_button_text(trait_data: TraitData) -> String:
	var equipped_marker = ""
	if TraitInventory.get_equipped(current_selected_slot) == trait_data:
		equipped_marker = " *"
	return "%s [%s]%s" % [trait_data.display_name, trait_data.equip_cost, equipped_marker]

# Fungsi akhir saat tombol trait ditekan
func _on_trait_clicked(trait_id: String):
	if player and player.has_method("ubah_organ_tubuh"):
		# Kirim data ke player: slot apa yang diubah, dan ditukar pakai trait apa
		player.ubah_organ_tubuh(current_selected_slot, trait_id)

func _on_unequip_clicked() -> void:
	if player and player.has_method("lepas_organ_tubuh"):
		player.lepas_organ_tubuh(current_selected_slot)
	
