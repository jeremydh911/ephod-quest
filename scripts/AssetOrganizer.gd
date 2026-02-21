extends Node
# ─────────────────────────────────────────────────────────────────────────────
# AssetOrganizer.gd  –  Tool to organize raw images into asset folders
# Run this in Godot editor to rename and move img_01.jpg etc. to proper names.
# "Let all things be done decently and in order" – 1 Corinthians 14:40
# ─────────────────────────────────────────────────────────────────────────────

@tool

# Mapping of raw image names to organized paths
# Based on visual inspection of images (update as needed)
const IMAGE_MAPPING: Dictionary = {
	"img_01.jpg": "characters/reuben_avatar.png",
	"img_02.jpg": "characters/reuben_elder.png",
	"img_03.jpg": "characters/simeon_avatar.png",
	"img_04.jpg": "characters/simeon_elder.png",
	"img_05.jpg": "characters/levi_avatar.png",
	"img_06.jpg": "characters/levi_elder.png",
	"img_07.jpg": "characters/judah_avatar.png",
	"img_08.jpg": "characters/judah_elder.png",
	"img_09.jpg": "characters/dan_avatar.png",
	"img_10.jpg": "characters/dan_elder.png",
	"img_11.jpg": "characters/naphtali_avatar.png",
	"img_12.jpg": "characters/naphtali_elder.png",
	"img_13.jpg": "characters/gad_avatar.png",
	"img_14.jpg": "characters/gad_elder.png",
	"img_15.jpg": "characters/asher_avatar.png",
	"img_16.jpg": "characters/asher_elder.png",
	"img_17.jpg": "characters/issachar_avatar.png",
	"img_18.jpg": "characters/issachar_elder.png",
	"img_19.jpg": "characters/zebulun_avatar.png",
	"img_20.jpg": "characters/zebulun_elder.png",
	"img_21.jpg": "characters/joseph_avatar.png",
	"img_22.jpg": "characters/joseph_elder.png",
	"img_23.jpg": "characters/benjamin_avatar.png",
	"img_24.jpg": "characters/benjamin_elder.png",
	"img_25.jpg": "backgrounds/desert_background.png",
	"img_26.jpg": "backgrounds/village_background.png",
	"img_27.jpg": "backgrounds/sea_background.png",
	"img_28.jpg": "action_spots/jericho_wall.png",
	"img_29.jpg": "action_spots/lion_rock.png",
	"img_30.jpg": "action_spots/golden_pillars.png",
	"img_31.jpg": "items/sardius_gem.png",
	"img_32.jpg": "items/emerald_gem.png",
	"img_33.jpg": "items/sapphire_gem.png",
	"img_34.jpg": "items/diamond_gem.png",
	"img_35.jpg": "ui/button_normal.png",
	# Add tile sheets
	"img_36.jpg": "tiles/desert_tiles.png",
	"img_37.jpg": "tiles/village_tiles.png",
	"img_38.jpg": "tiles/sea_tiles.png",
	"img_39.jpg": "tiles/action_spots_tiles.png",
}

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	organize_assets()

func organize_assets() -> void:
	var raw_dir := "res://assets/sprites/raw/"
	var base_dir := "res://assets/sprites/"
	
	var dir := DirAccess.open(raw_dir)
	if not dir:
		push_error("Cannot open raw directory: " + raw_dir)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".jpg") or file_name.ends_with(".png"):
			var new_path := IMAGE_MAPPING.get(file_name, "")
			if new_path != "":
				var full_old := raw_dir + file_name
				var full_new := base_dir + new_path
				# Ensure target directory exists
				var target_dir := full_new.get_base_dir()
				var target_da := DirAccess.open(target_dir)
				if not target_da:
					DirAccess.make_dir_recursive_absolute(target_dir)
				# Copy file (DirAccess doesn't have move, so copy and delete)
				if DirAccess.copy_absolute(full_old, full_new) == OK:
					DirAccess.remove_absolute(full_old)
					print("Moved: " + file_name + " -> " + new_path)
				else:
					push_error("Failed to move: " + file_name)
			else:
				print("No mapping for: " + file_name)
		file_name = dir.get_next()
	
	print("Asset organization complete!")

# Call this from editor by running the scene or attaching to a node