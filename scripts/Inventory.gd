# ─────────────────────────────────────────────────────────────────────────────
# Inventory.gd  –  Twelve Stones / Ephod Quest
# Collectibles system for 12 ephod stones, artifacts, scrolls, and technology.
# Supports RigidBody2D physics for pickups and shader effects for power-ups.
#
# Usage:
#   Inventory.add_item("sardius_stone")
#   Inventory.apply_power_up("bible_glow", player_node)
#
# "Better is a little with the fear of the LORD than great treasure" – Proverbs 15:16
# ─────────────────────────────────────────────────────────────────────────────

extends Node

# ── Item definitions ─────────────────────────────────────────────────────────
const ITEMS: Dictionary = {
	# Ephod stones (Exodus 28)
	"sardius_stone":   {"type": "stone", "tribe": "reuben",   "description": "Ruby red stone of Reuben"},
	"topaz_stone":     {"type": "stone", "tribe": "simeon",   "description": "Golden topaz of Simeon"},
	"carbuncle_stone": {"type": "stone", "tribe": "levi",     "description": "Emerald carbuncle of Levi"},
	"emerald_stone":   {"type": "stone", "tribe": "judah",    "description": "Green emerald of Judah"},
	"sapphire_stone":  {"type": "stone", "tribe": "dan",      "description": "Blue sapphire of Dan"},
	"diamond_stone":   {"type": "stone", "tribe": "naphtali", "description": "Clear diamond of Naphtali"},
	"jacinth_stone":   {"type": "stone", "tribe": "gad",      "description": "Red jacinth of Gad"},
	"agate_stone":     {"type": "stone", "tribe": "asher",    "description": "Blue agate of Asher"},
	"amethyst_stone":  {"type": "stone", "tribe": "issachar", "description": "Purple amethyst of Issachar"},
	"chrysolite_stone":{"type": "stone", "tribe": "zebulun",  "description": "Amber chrysolite of Zebulun"},
	"beryl_stone":     {"type": "stone", "tribe": "joseph",   "description": "Green beryl of Joseph"},
	"jasper_stone":    {"type": "stone", "tribe": "benjamin", "description": "Red jasper of Benjamin"},
	
	# Artifacts and scrolls
	"ancient_scroll":  {"type": "artifact", "description": "Scroll with biblical wisdom"},
	"golden_calf":     {"type": "artifact", "description": "Warning against idolatry"},
	"manna_jar":       {"type": "artifact", "description": "Heavenly bread container"},
	
	# Technology (biblical tech hidden in sand)
	"urim_thummim":    {"type": "technology", "description": "Priestly decision stones"},
	"ark_cover":       {"type": "technology", "description": "Mercy seat covering"},
	"ephod_threads":   {"type": "technology", "description": "Golden weaving threads"},
}

# ── Power-ups ───────────────────────────────────────────────────────────────
const POWER_UPS: Dictionary = {
	"bible_glow":     {"effect": "glow", "duration": 30.0, "shader": "res://shaders/bible_glow.tres"},
	"prayer_power":   {"effect": "speed_boost", "duration": 15.0, "multiplier": 1.5},
	"stone_wisdom":   {"effect": "hint_reveal", "duration": 60.0},
	"miracle_shield": {"effect": "invulnerability", "duration": 10.0},
}

# ── Inventory storage ────────────────────────────────────────────────────────
var collected_items: Array[String] = []
var active_power_ups: Dictionary = {}

# ── Signals ──────────────────────────────────────────────────────────────────
signal item_added(item_id: String)
signal item_removed(item_id: String)
signal power_up_applied(power_up_id: String)
signal power_up_expired(power_up_id: String)

func _ready() -> void:
	# Load from Global if available
	if Global.has_method("get_inventory"):
		collected_items = Global.get_inventory().duplicate()

func add_item(item_id: String) -> void:
	if ITEMS.has(item_id) and not collected_items.has(item_id):
		collected_items.append(item_id)
		item_added.emit(item_id)
		
		# Special handling for stones
		if ITEMS[item_id]["type"] == "stone":
			Global.add_stone(item_id)

func remove_item(item_id: String) -> void:
	if collected_items.has(item_id):
		collected_items.erase(item_id)
		item_removed.emit(item_id)

func has_item(item_id: String) -> bool:
	return collected_items.has(item_id)

func get_items_by_type(item_type: String) -> Array[String]:
	var result: Array[String] = []
	for item_id in collected_items:
		if ITEMS.get(item_id, {}).get("type") == item_type:
			result.append(item_id)
	return result

func apply_power_up(power_up_id: String, target: Node3D) -> void:
	if not POWER_UPS.has(power_up_id):
		return
	
	var power_data: Dictionary = POWER_UPS[power_up_id]
	active_power_ups[power_up_id] = Time.get_ticks_msec() + (power_data["duration"] * 1000)
	
	match power_data["effect"]:
		"glow":
			_apply_glow_effect(target, power_data)
		"speed_boost":
			_apply_speed_boost(target, power_data)
		"hint_reveal":
			_apply_hint_reveal(target, power_data)
		"invulnerability":
			_apply_invulnerability(target, power_data)
	
	power_up_applied.emit(power_up_id)

func _apply_glow_effect(target: Node3D, power_data: Dictionary) -> void:
	var shader_path: String = power_data.get("shader", "")
	if shader_path != "" and ResourceLoader.exists(shader_path):
		var material := ShaderMaterial.new()
		material.shader = load(shader_path)
		target.material = material
		
		# Tween the effect
		var tween := target.create_tween()
		tween.tween_property(material, "shader_parameter/glow_intensity", 1.0, 0.5)
		tween.tween_interval(power_data["duration"] - 1.0)
		tween.tween_property(material, "shader_parameter/glow_intensity", 0.0, 0.5)
		tween.tween_callback(func(): target.material = null)

func _apply_speed_boost(target: Node3D, power_data: Dictionary) -> void:
	if target.has_method("set_speed_multiplier"):
		var multiplier: float = power_data.get("multiplier", 1.0)
		target.set_speed_multiplier(multiplier)
		
		# Schedule removal
		var timer := Timer.new()
		timer.wait_time = power_data["duration"]
		timer.one_shot = true
		timer.timeout.connect(func(): target.set_speed_multiplier(1.0); timer.queue_free())
		target.add_child(timer)
		timer.start()

func _apply_hint_reveal(target: Node3D, power_data: Dictionary) -> void:
	# Reveal hidden hints in the world
	Global.reveal_hints(true)
	
	var timer := Timer.new()
	timer.wait_time = power_data["duration"]
	timer.one_shot = true
	timer.timeout.connect(func(): Global.reveal_hints(false); timer.queue_free())
	target.add_child(timer)
	timer.start()

func _apply_invulnerability(target: Node3D, power_data: Dictionary) -> void:
	if target.has_method("set_invulnerable"):
		target.set_invulnerable(true)
		
		var timer := Timer.new()
		timer.wait_time = power_data["duration"]
		timer.one_shot = true
		timer.timeout.connect(func(): target.set_invulnerable(false); timer.queue_free())
		target.add_child(timer)
		timer.start()

func _process(delta: float) -> void:
	# Check for expired power-ups
	var current_time := Time.get_ticks_msec()
	for power_up_id in active_power_ups.keys():
		if current_time > active_power_ups[power_up_id]:
			power_up_expired.emit(power_up_id)
			active_power_ups.erase(power_up_id)

# ── Pickup creation ──────────────────────────────────────────────────────────
static func create_pickup(item_id: String, position: Vector3, parent: Node) -> RigidBody3D:
	var pickup := RigidBody3D.new()
	pickup.name = item_id + "_pickup"
	pickup.position = position
	
	var collision := CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = 16.0
	pickup.add_child(collision)
	
	var sprite := Sprite3D.new()
	var texture_path := "res://assets/sprites/items/" + item_id + ".png"
	if ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)
	pickup.add_child(sprite)
	
	# Add glow effect for stones
	if ITEMS.get(item_id, {}).get("type") == "stone":
		var glow := Sprite3D.new()
		glow.texture = null  # Use modulate
		glow.modulate = Color(1, 1, 0.5, 0.3)
		pickup.add_child(glow)
	
	parent.add_child(pickup)
	return pickup

# ── Serialization ────────────────────────────────────────────────────────────
func to_dict() -> Dictionary:
	return {
		"collected_items": collected_items,
		"active_power_ups": active_power_ups,
	}

func from_dict(data: Dictionary) -> void:
	collected_items = data.get("collected_items", [])
	active_power_ups = data.get("active_power_ups", {})