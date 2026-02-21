extends Area3D
# ─────────────────────────────────────────────────────────────────────────────
# NPC.gd  –  Twelve Stones / Ephod Quest
# Interactable non-player character with multi-line dialogue.
# Attach to: Area3D  →  add CollisionShape3D + Sprite3D/Label children.
#
# Usage in scene:
#   $ElderHanoch.dialogue_lines = [
#     {"name": "Elder Hanoch", "text": "My child, shalom…"},
#     …
#   ]
#   $ElderHanoch.interaction_label = "✦ Speak with Elder Hanoch"
#
# "The lips of the wise spread knowledge" – Proverbs 15:7
# ─────────────────────────────────────────────────────────────────────────────

signal dialogue_finished

@export var npc_name:          String = "Elder"
@export var interaction_label: String = "✦ Speak"
@export var give_side_quest:   String = ""   # side quest ID to assign on first talk
@export var complete_side_quest: String = "" # side quest ID completed by talking here

# Set these at runtime from the World script
var dialogue_lines: Array = []
var repeat_lines:   Array = []   # after first talk

var _talked_once: bool = false

# Exclamation bubble (shown when player is nearby)
var _bubble: Label

func _ready() -> void:
	monitoring = true
	monitorable = true
	_build_bubble()
	_build_mesh()

func _build_mesh() -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1, 2, 1)
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.6, 0.4)  # skin tone
	# Load texture if available
	var texture_path := "res://assets/textures/" + npc_name.to_lower() + ".jpg"
	if ResourceLoader.exists(texture_path):
		material.albedo_texture = load(texture_path)
	mesh_instance.material_override = material
	add_child(mesh_instance)

func _build_bubble() -> void:
	_bubble = Label3D.new()
	_bubble.text = "!"
	_bubble.font_size = 24
	_bubble.modulate = Color(1, 0.9, 0.2, 1)
	_bubble.visible  = false
	_bubble.position = Vector3(-0.5, 2.0, 0)  # Above the NPC
	add_child(_bubble)
	_bubble.set_meta("_tween", null)

func get_interaction_label() -> String:
	return "✦ Speak with " + npc_name

# ─────────────────────────────────────────────────────────────────────────────
# Called by WorldBase when player presses interact near this NPC
# ─────────────────────────────────────────────────────────────────────────────
func on_interact(world: Node) -> void:
	if not world.has_method("show_dialogue"):
		return

	# Give side quest if this is first interaction
	if give_side_quest != "" and not SideQuestManager.is_quest_active(give_side_quest):
		SideQuestManager.give_quest(give_side_quest, world)

	# Complete side quest if applicable
	if complete_side_quest != "" and SideQuestManager.is_quest_active(complete_side_quest):
		SideQuestManager.complete_quest(complete_side_quest, world)

	var lines: Array = dialogue_lines if not _talked_once else repeat_lines
	if lines.is_empty():
		lines = [{"name": npc_name, "text": "Shalom, shalom."}]

	# Connect to know when dialogue ends
	if not world.is_connected("_dialogue_queue_empty", Callable(self, "_on_dialogue_done")):
		pass  # WorldBase handles the signal internally

	world.show_dialogue(lines)
	_talked_once = true
	_bubble.visible = false

# ─────────────────────────────────────────────────────────────────────────────
# BUBBLE pulse when player enters range
# ─────────────────────────────────────────────────────────────────────────────
func show_nearby() -> void:
	_bubble.visible = true
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(_bubble, "position:y", -62.0, 0.6).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_bubble, "position:y", -52.0, 0.6).set_ease(Tween.EASE_IN_OUT)
	_bubble.set_meta("_tween", tw)

func hide_nearby() -> void:
	_bubble.visible = false
	var tw = _bubble.get_meta("_tween")
	if tw is Tween:
		(tw as Tween).kill()
