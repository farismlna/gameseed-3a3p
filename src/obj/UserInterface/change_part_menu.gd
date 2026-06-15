extends Node2D

# Referensi ke Node UI menggunakan path sesuai gambar Anda
@onready var ui_container = $Control
@onready var sub_menu = $Control/HBoxContainer/SubMain

# Mengambil referensi Node Player dan Kamera di ruang 3D secara absolut
@onready var player = get_node("../Player")
@onready var camera = get_node("../PlayerCam")

# Atur jarak melayang UI di seblah kanan Player (dalam satuan pixel)
@export var ui_offset: Vector2 = Vector2(120,-6)

# Variabel untuk mencatat slot apa yang sedang dipilih oleh pemain
var current_selected_slot: String = ""

func _ready():
	# 1. Sembunyikan seluruh UI dan SubMain saat game dimulai
	ui_container.hide()
	sub_menu.hide()
	
	# 2. Hubungkan sinyal tombol menu utama ke fungsi logikanya
	$Control/HBoxContainer/Main/BtnHead.pressed.connect(func(): _on_slot_clicked("head"))
	$Control/HBoxContainer/Main/BtnHand.pressed.connect(func(): _on_slot_clicked("hand"))
	$Control/HBoxContainer/Main/BtnLeg.pressed.connect(func(): _on_slot_clicked("legs"))
	$Control/HBoxContainer/Main/BtnBody.pressed.connect(func(): _on_slot_clicked("body"))
	
	# 3. Hubungkan tombol Trait ke fungsi eksekusi transformasi
	# (Di sini kita asumsikan Button = Trait 1, Button2 = Trait 2, dst)
	$Control/HBoxContainer/SubMain/Button.pressed.connect(func(): _on_trait_clicked("trait_1"))
	$Control/HBoxContainer/SubMain/Button2.pressed.connect(func(): _on_trait_clicked("trait_2"))
	$Control/HBoxContainer/SubMain/Button3.pressed.connect(func(): _on_trait_clicked("trait_3"))

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
	
	# Update teks tombol sub-menu secara dinamis agar tahu sedang memilih apa (Opsional tapi keren!)
	$Control/HBoxContainer/SubMain/Button.text = slot_name.to_upper() + " - Trait 1"
	$Control/HBoxContainer/SubMain/Button2.text = slot_name.to_upper() + " - Trait 2"
	$Control/HBoxContainer/SubMain/Button3.text = slot_name.to_upper() + " - Trait 3"
	
	# Munculkan sub-menu di sebelah kanan
	sub_menu.show()

# Fungsi akhir saat tombol Trait 1/2/3 ditekan
func _on_trait_clicked(trait_name: String):
	var player = get_parent() # Mengambil node Player (CharacterBody2D) tempat UI ini menempel
	
	if player and player.has_method("ubah_organ_tubuh"):
		# Kirim data ke player: slot apa yang diubah, dan ditukar pakai trait apa
		player.ubah_organ_tubuh(current_selected_slot, trait_name)
	
