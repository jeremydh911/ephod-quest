extends Node
# ─────────────────────────────────────────────────────────────────────────────
# SideQuestManager.gd  –  Twelve Stones / Ephod Quest
# Autoload singleton for tracking all side quests across all 12 worlds.
# Register as autoload: SideQuestManager
#
# "I press on toward the goal" – Philippians 3:14
# ─────────────────────────────────────────────────────────────────────────────

signal quest_given(quest_id: String)
signal quest_completed(quest_id: String)
signal item_collected(item_id: String)

# ── Side Quest Definitions ────────────────────────────────────────────────────
# Each entry: description, steps (Array of String), reward_verse_ref, reward_verse
const SIDE_QUESTS: Dictionary = {
	# ── REUBEN (World 1 – Morning Cliffs) ────────────────────────────────────
	"reuben_lost_lamb": {
		"tribe": "reuben", "world": 1,
		"name": "The Lost Lamb",
		"description": "Three lambs strayed from the flock in the cliffs. Find and guide each one home.",
		"steps": ["Find Lamb 1 (near the east rock)", "Find Lamb 2 (below the waterfall)", "Find Lamb 3 (in the cave alcove)"],
		"required_items": ["lamb_1", "lamb_2", "lamb_3"],
		"reward_verse_ref": "Psalm 23:1",
		"reward_verse": "The LORD is my shepherd, I lack nothing."
	},
	"reuben_torch_light": {
		"tribe": "reuben", "world": 1,
		"name": "Light the Watchtower",
		"description": "Three watchtower torches have gone out. Light them in order: east, centre, west.",
		"steps": ["Light the east torch", "Light the centre torch", "Light the west torch"],
		"required_items": ["torch_east", "torch_centre", "torch_west"],
		"reward_verse_ref": "Matthew 5:16",
		"reward_verse": "Let your light shine before others, that they may see your good deeds and glorify your Father in heaven."
	},
	"reuben_herbs": {
		"tribe": "reuben", "world": 1,
		"name": "Healing Herbs",
		"description": "Elder Hanoch needs four healing herbs for the village. They grow hidden across the cliff.",
		"steps": ["Collect herb near the north path", "Collect herb in the cave", "Collect herb by the stream", "Collect herb on the high ledge"],
		"required_items": ["herb_1", "herb_2", "herb_3", "herb_4"],
		"reward_verse_ref": "Ezekiel 47:12",
		"reward_verse": "Their fruit will serve for food and their leaves for healing."
	},
	# ── SIMEON (World 2 – Desert Border) ────────────────────────────────────
	"simeon_silence_stones": {
		"tribe": "simeon", "world": 2,
		"name": "Stones of Stillness",
		"description": "Place five smooth stones in the silent altar circle. Listen for where each belongs.",
		"steps": ["Find and place stone 1", "Find and place stone 2", "Find and place stone 3", "Find and place stone 4", "Find and place stone 5"],
		"required_items": ["still_stone_1","still_stone_2","still_stone_3","still_stone_4","still_stone_5"],
		"reward_verse_ref": "Psalm 46:10",
		"reward_verse": "Be still, and know that I am God."
	},
	"simeon_shepherd_call": {
		"tribe": "simeon", "world": 2,
		"name": "Voice of the Shepherd",
		"description": "Five sheep refuse to move. Stand near each one and hold the call button until they hear and follow.",
		"steps": ["Call Sheep A", "Call Sheep B", "Call Sheep C", "Call Sheep D", "Call Sheep E"],
		"required_items": ["sheep_a","sheep_b","sheep_c","sheep_d","sheep_e"],
		"reward_verse_ref": "John 10:27",
		"reward_verse": "My sheep listen to my voice; I know them, and they follow me."
	},
	# ── LEVI (World 3 – Lampstand Hall) ─────────────────────────────────────
	"levi_sevenfold_lamp": {
		"tribe": "levi", "world": 3,
		"name": "Sevenfold Lamp",
		"description": "The seven-flame lampstand has only two flames lit. Solve the scroll riddles to light the others.",
		"steps": ["Read Scroll 1", "Read Scroll 2", "Read Scroll 3", "Read Scroll 4", "Read Scroll 5"],
		"required_items": ["scroll_1","scroll_2","scroll_3","scroll_4","scroll_5"],
		"reward_verse_ref": "Revelation 4:5",
		"reward_verse": "From the throne came flashes of lightning… In front of the throne, seven lamps were blazing."
	},
	# ── JUDAH (World 4 – Savannah Ridge) ────────────────────────────────────
	"judah_praise_stones": {
		"tribe": "judah", "world": 4,
		"name": "Stones of Praise",
		"description": "Collect 7 praise stones scattered across the ridge and bring them to the singing circle.",
		"steps": ["Find praise stone 1","Find praise stone 2","Find praise stone 3","Find praise stone 4","Find praise stone 5","Find praise stone 6","Find praise stone 7"],
		"required_items": ["ps_1","ps_2","ps_3","ps_4","ps_5","ps_6","ps_7"],
		"reward_verse_ref": "Psalm 100:4",
		"reward_verse": "Enter his gates with thanksgiving and his courts with praise; give thanks to him and praise his name."
	},
	# ── DAN (World 5 – Eagle Cliffs) ─────────────────────────────────────────
	"dan_riddle_trail": {
		"tribe": "dan", "world": 5,
		"name": "The Eagle's Riddle Trail",
		"description": "Three riddle tablets are hidden in the cliffs. Solve each one to reveal Dan's wisdom treasure.",
		"steps": ["Solve Riddle 1", "Solve Riddle 2", "Solve Riddle 3"],
		"required_items": ["riddle_1","riddle_2","riddle_3"],
		"reward_verse_ref": "Proverbs 2:6",
		"reward_verse": "For the LORD gives wisdom; from his mouth come knowledge and understanding."
	},
	# ── NAPHTALI (World 6 – Twilight Meadow) ─────────────────────────────────
	"naphtali_good_news": {
		"tribe": "naphtali", "world": 6,
		"name": "Carry the Good News",
		"description": "Deliver messages to five elders scattered across the meadow before sundown.",
		"steps": ["Deliver to Elder 1","Deliver to Elder 2","Deliver to Elder 3","Deliver to Elder 4","Deliver to Elder 5"],
		"required_items": ["msg_1","msg_2","msg_3","msg_4","msg_5"],
		"reward_verse_ref": "Isaiah 52:7",
		"reward_verse": "How beautiful on the mountains are the feet of those who bring good news."
	},
	# ── GAD (World 7 – Mountain Pass) ────────────────────────────────────────
	"gad_broken_bridge": {
		"tribe": "gad", "world": 7,
		"name": "The Broken Bridge",
		"description": "Find four broken bridge planks hidden across the mountain; bring them to the carpenter.",
		"steps": ["Find plank 1","Find plank 2","Find plank 3","Find plank 4"],
		"required_items": ["plank_1","plank_2","plank_3","plank_4"],
		"reward_verse_ref": "Nehemiah 2:20",
		"reward_verse": "The God of heaven will give us success. We his servants will start rebuilding."
	},
	# ── ASHER (World 8 – Coastal Shore) ──────────────────────────────────────
	"asher_bread_baskets": {
		"tribe": "asher", "world": 8,
		"name": "Five Loaves",
		"description": "Asher blesses with bread. Deliver five full bread baskets to the waiting families.",
		"steps": ["Bake and deliver basket 1","Bake and deliver basket 2","Bake and deliver basket 3","Bake and deliver basket 4","Bake and deliver basket 5"],
		"required_items": ["basket_1","basket_2","basket_3","basket_4","basket_5"],
		"reward_verse_ref": "Matthew 14:19",
		"reward_verse": "He directed the people to sit down on the grass. Taking the five loaves and the two fish and looking up to heaven, he gave thanks."
	},
	# ── ISSACHAR (World 9 – Night Observatory) ───────────────────────────────
	"issachar_star_map": {
		"tribe": "issachar", "world": 9,
		"name": "Map the Heavens",
		"description": "Chart six star clusters on the stone sky-map. Each cluster matches a verse about creation.",
		"steps": ["Chart cluster 1","Chart cluster 2","Chart cluster 3","Chart cluster 4","Chart cluster 5","Chart cluster 6"],
		"required_items": ["star_1","star_2","star_3","star_4","star_5","star_6"],
		"reward_verse_ref": "Psalm 19:1",
		"reward_verse": "The heavens declare the glory of God; the skies proclaim the work of his hands."
	},
	# ── ZEBULUN (World 10 – Harbour Dawn) ────────────────────────────────────
	"zebulun_fisher_nets": {
		"tribe": "zebulun", "world": 10,
		"name": "Cast the Nets",
		"description": "Three fishing nets have drifted. Swim out and retrieve each one before the tide turns.",
		"steps": ["Retrieve net 1","Retrieve net 2","Retrieve net 3"],
		"required_items": ["net_1","net_2","net_3"],
		"reward_verse_ref": "John 21:6",
		"reward_verse": "He said, 'Throw your net on the right side of the boat and you will find some.'"
	},
	# ── JOSEPH (World 11 – Orchard Valley) ───────────────────────────────────
	"joseph_dream_scrolls": {
		"tribe": "joseph", "world": 11,
		"name": "Dreams and Plans",
		"description": "Joseph's dream scrolls are scattered. Collect five and return them to the elder.",
		"steps": ["Collect scroll 1","Collect scroll 2","Collect scroll 3","Collect scroll 4","Collect scroll 5"],
		"required_items": ["dream_1","dream_2","dream_3","dream_4","dream_5"],
		"reward_verse_ref": "Genesis 50:20",
		"reward_verse": "You intended to harm me, but God intended it for good to accomplish what is now being done."
	},
	# ── BENJAMIN (World 12 – Amber Forest) ───────────────────────────────────
	"benjamin_wolf_watch": {
		"tribe": "benjamin", "world": 12,
		"name": "Wolf Watch",
		"description": "The forest wolves are just curious — befriend each one by bringing it a gift of bread.",
		"steps": ["Befriend wolf 1","Befriend wolf 2","Befriend wolf 3"],
		"required_items": ["wolf_1","wolf_2","wolf_3"],
		"reward_verse_ref": "Isaiah 11:6",
		"reward_verse": "The wolf will live with the lamb, the leopard will lie down with the goat…"
	},
}

# ── Runtime state ─────────────────────────────────────────────────────────────
var active_quests:    Dictionary = {}   # quest_id → {steps_done: Array[String]}
var completed_ids:    Array[String] = []
var collected_items:  Array[String] = []

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_load_state()

# ─────────────────────────────────────────────────────────────────────────────
# QUEST API
# ─────────────────────────────────────────────────────────────────────────────
func give_quest(quest_id: String, world: Node) -> void:
	if is_quest_active(quest_id) or is_completed(quest_id):
		return
	active_quests[quest_id] = {"steps_done": []}
	quest_given.emit(quest_id)
	_save_state()
	# Update world HUD
	var def: Dictionary = SIDE_QUESTS.get(quest_id, {}) as Dictionary
	if world.has_method("update_quest_log"):
		world.update_quest_log("📜 New: " + (def.get("name", quest_id) as String))

func complete_quest(quest_id: String, world: Node) -> void:
	if not is_quest_active(quest_id):
		return
	var def: Dictionary = SIDE_QUESTS.get(quest_id, {}) as Dictionary
	active_quests.erase(quest_id)
	completed_ids.append(quest_id)
	Global.completed_quests.append(quest_id)
	quest_completed.emit(quest_id)
	_save_state()
	Global.save_game()
	# Show reward
	var vref: String  = def.get("reward_verse_ref", "") as String
	var vtext: String = def.get("reward_verse",     "") as String
	if vref != "" and world.has_method("show_verse_scroll"):
		world.show_verse_scroll(vref, vtext)
	if world.has_method("update_quest_log"):
		world.update_quest_log("✦ Complete: " + (def.get("name", quest_id) as String))

func collect_item(item_id: String, world: Node) -> void:
	if collected_items.has(item_id):
		return
	collected_items.append(item_id)
	item_collected.emit(item_id)
	# Check if this completes any active quest
	for qid: String in active_quests.keys():
		var def: Dictionary = SIDE_QUESTS.get(qid, {}) as Dictionary
		var required: Array = def.get("required_items", []) as Array
		var done: Array = active_quests[qid].get("steps_done", []) as Array
		if required.has(item_id) and not done.has(item_id):
			done.append(item_id)
			active_quests[qid]["steps_done"] = done
			# Check if all items collected
			var all_done := true
			for req_item in required:
				if not done.has(req_item):
					all_done = false
					break
			if all_done:
				complete_quest(qid, world)
				return
	# Update world quest log with progress
	if world.has_method("update_quest_log"):
		world.update_quest_log("  ✓ Found: " + item_id.replace("_", " "))
	_save_state()

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_completed(quest_id: String) -> bool:
	return completed_ids.has(quest_id)

func get_active_for_tribe(tribe: String) -> Array[String]:
	var result: Array[String] = []
	for qid: String in active_quests.keys():
		var def: Dictionary = SIDE_QUESTS.get(qid, {}) as Dictionary
		if def.get("tribe", "") == tribe:
			result.append(qid)
	return result

# ─────────────────────────────────────────────────────────────────────────────
# PERSISTENCE
# ─────────────────────────────────────────────────────────────────────────────
const SQ_SAVE := "user://side_quests.json"

func _save_state() -> void:
	var data: Dictionary = {
		"active":    active_quests,
		"completed": completed_ids,
		"items":     collected_items,
	}
	var f := FileAccess.open(SQ_SAVE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func _load_state() -> void:
	if not FileAccess.file_exists(SQ_SAVE):
		return
	var f := FileAccess.open(SQ_SAVE, FileAccess.READ)
	if not f:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed == null:
		return
	var data: Dictionary = parsed as Dictionary
	active_quests   = data.get("active",    {}) as Dictionary
	completed_ids   = Array(data.get("completed", []), TYPE_STRING, "", null)
	collected_items = Array(data.get("items",     []), TYPE_STRING, "", null)
