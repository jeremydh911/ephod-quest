extends Area3D

# ─────────────────────────────────────────────────────────────────────────────
# TreasureChest.gd  –  Twelve Stones / Ephod Quest
# Interactable hidden treasure chest.
# Opened once; rewards can be: a verse, a nature fact, a heart badge,
# a side-quest item, or a world hint.
#
# Attach to: Area3D with CollisionShape3D child.
# Add a MeshInstance or Sprite3D child for the visual.
#
# "The kingdom of heaven is like treasure hidden in a field" – Matthew 13:44
# ─────────────────────────────────────────────────────────────────────────────

signal chest_opened(chest_id: String)

@export var chest_id: String = "" # unique per world e.g. "reuben_chest1"
@export var chest_label: String = "✦ Open Treasure"
@export var reward_type: String = "verse" # "verse" | "item" | "side_quest_item"
@export var reward_id: String = "" # verse ref OR item name
@export var reward_text: String = "" # verse text or item description
@export var starts_hidden: bool = true # starts dim, brightens when player nears

var _opened: bool = false
var _glow_rect: ColorRect # the visual of the chest box


func _ready() -> void:
	monitoring = true
	monitorable = true
	_opened = Global.treasures_found.has(chest_id) if chest_id != "" else false

	# Visual: a golden chest mesh
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1, 0.5, 0.8)
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.62, 0.12, 1) if not _opened else Color(0.3, 0.3, 0.3, 0.5)
	mesh_instance.material_override = material
	add_child(mesh_instance)

	# Label3D for star
	var star := Label3D.new()
	star.text = "✦" if not _opened else "○"
	star.font_size = 24
	star.modulate = Color(1, 0.9, 0.2, 0.9) if not _opened else Color(0.4, 0.4, 0.4, 0.5)
	star.position = Vector3(0, 1, 0)
	add_child(star)

	if starts_hidden and not _opened:
		modulate = Color(1, 1, 1, 0.35) # dim until player is nearby


func get_interaction_label() -> String:
	if _opened:
		return "○ (Already opened)"
	return chest_label


# ─────────────────────────────────────────────────────────────────────────────
# Called by WorldBase when player interacts
# ─────────────────────────────────────────────────────────────────────────────
func on_interact(world: Node) -> void:
	if _opened:
		if world.has_method("show_dialogue"):
			world.show_dialogue(
				[
					{
						"name": "Chest",
						"text": "This chest is already open. But the verse within it remains in your heart.",
					},
				],
			)
		return

	_opened = true
	if chest_id != "" and not Global.treasures_found.has(chest_id):
		Global.treasures_found.append(chest_id)
		Global.save_game()

	_animate_open()
	chest_opened.emit(chest_id)

	# Show reward based on type
	match reward_type:
		"verse":
			if world.has_method("show_verse_scroll"):
				world.show_verse_scroll(reward_id, reward_text)
		"item":
			if world.has_method("show_dialogue"):
				world.show_dialogue(
					[
						{
							"name": "✦ Treasure Found",
							"text": "You found: " + reward_id + "\n" + reward_text,
						},
					],
				)
		"side_quest_item":
			if reward_id != "":
				SideQuestManager.collect_item(reward_id, world)
		_:
			if world.has_method("show_dialogue"):
				world.show_dialogue(
					[
						{
							"name": "✦ Treasure",
							"text": reward_text if reward_text != "" else "A precious find.",
						},
					],
				)


func _animate_open() -> void:
	# Pop open: flash gold, scale up
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	var mesh = get_node("MeshInstance")
	if mesh:
		var mat = mesh.material_override
		if mat:
			tw.tween_property(mat, "albedo_color", Color(1.0, 0.85, 0.2, 1), 0.15)
			tw.tween_property(mat, "albedo_color", Color(0.7, 0.55, 0.15, 1), 0.3)
	tw.parallel().tween_property(self, "scale", Vector3(1.15, 1.15, 1.15), 0.12).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.15)


# Brighten when player walks near (called by World script)
func pulse_nearby() -> void:
	if _opened:
		return
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)


func dim_away() -> void:
	if _opened or not starts_hidden:
		return
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.35, 0.6).set_ease(Tween.EASE_IN)
