# ─────────────────────────────────────────────────────────────────────────────
# WorldGenerator.gd  –  Twelve Stones / Ephod Quest
#
# Art-DNA-driven world system.  Every tribe zone is built from the visual
# language extracted from our 57 reference images: warm golden ambient,
# pastel + bright-natural-pop palette, diverse human characters, real
# biblical geography (Reuben's rocky cliffs → Naphtali's lush harp valleys).
#
# Usage:
#   var z := WorldGenerator.zone("judah")   # returns a WorldZone dict
#   var chars := WorldGenerator.spawn_characters("levi", 3)
#   var light := WorldGenerator.lighting_profile("golden_hour")
#
# "He set the earth on its foundations" – Psalm 104:5
# ─────────────────────────────────────────────────────────────────────────────
extends Node

# ── Palette – extracted from 57 reference images ────────────────────────────
# Every colour here appears in our reference art. NEVER use cold blues or
# harsh greys — every scene stays warm and inviting.  (Isaiah 60:1)
const PALETTE := {
	# Skin tones (diverse — all represented equally)
	"skin_pale": Color(0.98, 0.89, 0.80),
	"skin_light": Color(0.94, 0.80, 0.67),
	"skin_medium": Color(0.82, 0.64, 0.46),
	"skin_tan": Color(0.72, 0.52, 0.34),
	"skin_brown": Color(0.55, 0.36, 0.22),
	"skin_deep": Color(0.36, 0.22, 0.12),
	# Hair tones
	"hair_black": Color(0.12, 0.09, 0.07),
	"hair_dark_brown": Color(0.28, 0.17, 0.09),
	"hair_auburn": Color(0.52, 0.24, 0.10),
	"hair_golden": Color(0.86, 0.68, 0.22),
	"hair_silver": Color(0.82, 0.82, 0.80),
	# World — earth & gold
	"desert_sand": Color(0.914, 0.835, 0.702),
	"clay_brown": Color(0.545, 0.435, 0.278),
	"olive_green": Color(0.420, 0.475, 0.310),
	"pure_gold": Color(1.00, 0.843, 0.00),
	"antique_gold": Color(0.773, 0.647, 0.447),
	"cedar_wood": Color(0.620, 0.380, 0.220),
	# Sky / water
	"sky_dawn": Color(0.98, 0.72, 0.52),
	"sky_morning": Color(0.72, 0.88, 1.00),
	"sky_golden": Color(1.00, 0.82, 0.44),
	"sky_dusk": Color(0.92, 0.52, 0.32),
	"water_clear": Color(0.44, 0.76, 0.88),
	"water_deep": Color(0.24, 0.52, 0.72),
	# Vegetation
	"leaf_bright": Color(0.46, 0.72, 0.24),
	"leaf_olive": Color(0.52, 0.58, 0.30),
	"leaf_dry": Color(0.78, 0.68, 0.38),
	# Gem pops (Exodus 28 ephod rows)
	"ruby_red": Color(0.88, 0.12, 0.18),
	"topaz_amber": Color(1.00, 0.70, 0.12),
	"emerald_green": Color(0.08, 0.72, 0.30),
	"carbuncle_crimson": Color(0.78, 0.08, 0.28),
	"sapphire_blue": Color(0.12, 0.32, 0.88),
	"diamond_white": Color(0.96, 0.96, 1.00),
	"ligure_amber": Color(0.88, 0.62, 0.14),
	"agate_pink": Color(0.88, 0.56, 0.64),
	"amethyst_violet": Color(0.56, 0.28, 0.76),
	"beryl_seafoam": Color(0.22, 0.78, 0.68),
	"onyx_black": Color(0.14, 0.12, 0.16),
	"jasper_orange": Color(0.92, 0.46, 0.18),
}

# Warm golden ambient — applied to EVERY scene so nothing reads cold
# "The LORD is my light" – Psalm 27:1
const GLOBAL_AMBIENT_TINT := Color(1.0, 0.97, 0.88)


# ─────────────────────────────────────────────────────────────────────────────
# zone(tribe_key) → Dictionary
# Core data structure for every tribe world.  QuestBase reads this to build
# the sky gradient, ground, vegetation, elder NPC, character pool, and music.
# ─────────────────────────────────────────────────────────────────────────────
static func zone(tribe_key: String) -> Dictionary:
	return _build_zones().get(tribe_key, _build_zones()["reuben"])


static func _build_zones() -> Dictionary:
	return {
		# ── REUBEN – Morning Rocky Cliffs ────────────────────────────────────
		# Genesis 49:3 – "firstborn, my might…"
		# Geography: Jordan highlands, rugged terraces, morning mist over a stream
		"reuben": {
			"tribe_key": "reuben",
			"display_name": "Reuben – Morning Cliffs",
			"geography": "rocky highland terraces, cave mouths, a brook",
			"sky_top": Color(0.44, 0.60, 0.88),
			"sky_horizon": Color(0.98, 0.84, 0.62),
			"ground_color": Color(0.72, 0.58, 0.40),
			"accent_colors": [Color(0.52, 0.78, 0.94), Color(0.82, 0.68, 0.42)],
			"vegetation": ["sparse juniper", "rock-hyssop tufts", "morning-glory vines"],
			"terrain_features": ["limestone ledges", "cave entrance", "trickling brook"],
			"ambient_sounds": ["brook_trickle", "morning_birdsong", "wind_cliff"],
			"time_of_day": "morning",
			"light_direction": Vector2(0.6, -0.8),
			"music_track": "res://assets/audio/music/Lion of the Dawn.wav",
			"elder_name": "Hanoch",
			"elder_sprite": "res://assets/sprites/elders/elder_reuben.svg",
			"elder_skin": "skin_medium",
			"elder_greeting": "My child, shalom. The cliffs have watched the dawn rise for a thousand years.",
			"character_pool": _char_pool_reuben(),
			"nature_sprites": [
				"res://assets/sprites/nature/butterfly_colorful.svg",
				"res://assets/sprites/nature/sparrow.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/reuben_cliffs.svg",
			"quest_scene": "res://scenes/Quest1.tscn",
			"gem_color": Color(0.88, 0.12, 0.18), # ruby
			"gem_name": "Ruby",
			"verse_ref": "Proverbs 3:5-6",
			"verse_text": "Trust in the LORD with all your heart and lean not on your own understanding.",
			"nature_fact": "Butterflies taste with their feet — tiny sensors on their legs tell them if a leaf is food.",
		},

		# ── SIMEON – Dry Desert Plateau ──────────────────────────────────────
		# Genesis 49:5 – "Simeon and Levi are brothers…"
		# Geography: sun-baked plateau, sparse acacia, distant dunes
		"simeon": {
			"tribe_key": "simeon",
			"display_name": "Simeon – Desert Plateau",
			"geography": "sun-baked flat plateau, cracked earth, acacia shade",
			"sky_top": Color(0.62, 0.78, 1.00),
			"sky_horizon": Color(1.00, 0.82, 0.44),
			"ground_color": Color(0.88, 0.76, 0.52),
			"accent_colors": [Color(0.78, 0.60, 0.30), Color(1.00, 0.82, 0.28)],
			"vegetation": ["lone acacia tree", "desert thistle", "camel thorn"],
			"terrain_features": ["cracked clay flats", "distant dune ridge", "dried riverbed"],
			"ambient_sounds": ["desert_wind", "distant_camel", "cicada"],
			"time_of_day": "midday",
			"light_direction": Vector2(0.0, -1.0),
			"music_track": "res://assets/audio/music/Incense in the Vaulted Air.wav",
			"elder_name": "Nemuel",
			"elder_sprite": "res://assets/sprites/elders/elder_simeon.svg",
			"elder_skin": "skin_brown",
			"elder_greeting": "My child, even the desert blooms when rain finds its way. Shalom.",
			"character_pool": _char_pool_generic("simeon"),
			"nature_sprites": [
				"res://assets/sprites/nature/eagle_soaring.svg",
				"res://assets/sprites/nature/desert_lizard.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/simeon_desert.svg",
			"quest_scene": "res://scenes/Quest2.tscn",
			"gem_color": Color(0.78, 0.62, 0.20), # topaz
			"gem_name": "Topaz",
			"verse_ref": "Lamentations 3:22-23",
			"verse_text": "Because of the LORD's great love we are not consumed, for his compassions never fail.",
			"nature_fact": "Camels can drink 40 litres of water in one go and store energy (not water) in their humps.",
		},

		# ── LEVI – Lampstand Interior ─────────────────────────────────────────
		# Deuteronomy 33:10 – "He teaches your precepts to Jacob…"
		# Geography: cedar-beam hall, blue/purple/scarlet curtains, 7-flame lampstand
		"levi": {
			"tribe_key": "levi",
			"display_name": "Levi – Cedar Hall",
			"geography": "interior cedar hall, thick veil, 7-flame lampstand, incense altar",
			"sky_top": Color(0.18, 0.14, 0.32), # deep indigo ceiling
			"sky_horizon": Color(0.52, 0.36, 0.14), # cedar-warm wall
			"ground_color": Color(0.62, 0.46, 0.28), # polished cedar floor
			"accent_colors": [Color(0.12, 0.28, 0.72), Color(0.52, 0.12, 0.48), Color(0.88, 0.22, 0.14)],
			"vegetation": ["potted hyssop", "aloe vera near basin"],
			"terrain_features": [
				"gold-plated cedar pillars",
				"blue/purple/scarlet curtain",
				"incense altar",
				"seven-flame lampstand",
				"thick veil with embroidered cherubim",
			],
			"ambient_sounds": ["incense_crackle", "soft_choir", "scroll_rustle"],
			"time_of_day": "interior_lamp",
			"light_direction": Vector2(0.3, -0.5),
			"music_track": "res://assets/audio/music/Incense in the Vaulted Air.wav",
			"elder_name": "Gershom",
			"elder_sprite": "res://assets/sprites/elders/elder_levi.svg",
			"elder_skin": "skin_light",
			"elder_greeting": "My child, shalom. Come, the scroll has waited for you.",
			"character_pool": _char_pool_generic("levi"),
			"nature_sprites": ["res://assets/sprites/nature/dove.svg"],
			"bg_sprite": "res://assets/sprites/backgrounds/levi_cedar_hall.svg",
			"quest_scene": "res://scenes/Quest3.tscn",
			"gem_color": Color(0.08, 0.72, 0.30), # emerald
			"gem_name": "Carbuncle",
			"verse_ref": "Psalm 119:105",
			"verse_text": "Your word is a lamp for my feet, a light on my path.",
			"nature_fact": "Doves can find their way home from 1 600 km away using the Earth's magnetic field.",
		},

		# ── JUDAH – Sunlit Lion Hillside ──────────────────────────────────────
		# Genesis 49:9 – "Judah is a lion's cub…"
		# Geography: golden hillside, lion's den, cedar grove, sunrise glow
		"judah": {
			"tribe_key": "judah",
			"display_name": "Judah – Lion Hillside",
			"geography": "sunlit rolling hills, cedar grove spine, distant Bethlehem",
			"sky_top": Color(0.30, 0.52, 0.88),
			"sky_horizon": Color(1.00, 0.78, 0.36),
			"ground_color": Color(0.78, 0.66, 0.38),
			"accent_colors": [Color(1.00, 0.84, 0.00), Color(0.52, 0.72, 0.28)],
			"vegetation": ["cedar grove", "golden wheat field", "wild poppies"],
			"terrain_features": ["grassy knoll", "limestone watchtower ruin", "shepherd's path"],
			"ambient_sounds": ["lion_distant_roar", "wheat_wind", "praise_hum"],
			"time_of_day": "golden_hour",
			"light_direction": Vector2(-0.4, -0.7),
			"music_track": "res://assets/audio/music/Lion of the Dawn.wav",
			"elder_name": "Shelah",
			"elder_sprite": "res://assets/sprites/elders/elder_judah.svg",
			"elder_skin": "skin_tan",
			"elder_greeting": "My child, the lion does not roar by accident. There is a time for everything — shalom.",
			"character_pool": _char_pool_generic("judah"),
			"nature_sprites": [
				"res://assets/sprites/nature/lion.svg",
				"res://assets/sprites/nature/butterfly_colorful.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/judah_hillside.svg",
			"quest_scene": "res://scenes/Quest4.tscn",
			"gem_color": Color(0.88, 0.62, 0.14), # carbuncle / amber
			"gem_name": "Emerald",
			"verse_ref": "Revelation 5:5",
			"verse_text": "See, the Lion of the tribe of Judah, the Root of David, has triumphed.",
			"nature_fact": "A lion's roar can be heard from 8 kilometres away and shakes the ground underfoot.",
		},

		# ── DAN – Sea Cliffs at Dusk ──────────────────────────────────────────
		# Genesis 49:17 – "Dan will be a snake by the roadside…"
		# Geography: rocky coastal cliffs, crashing waves, smuggler's cove
		"dan": {
			"tribe_key": "dan",
			"display_name": "Dan – Sea Cliffs",
			"geography": "coastal limestone cliffs, sea cave, crashing Mediterranean waves",
			"sky_top": Color(0.20, 0.30, 0.68),
			"sky_horizon": Color(0.92, 0.52, 0.32),
			"ground_color": Color(0.56, 0.50, 0.42),
			"accent_colors": [Color(0.24, 0.52, 0.72), Color(0.88, 0.46, 0.18)],
			"vegetation": ["sea-thrift flowers", "cliff-edge fig tree", "kelp fronds"],
			"terrain_features": ["limestone cliff face", "sea cave mouth", "tidal rock pools", "rope bridge"],
			"ambient_sounds": ["waves_crash", "seabird_cry", "wind_cliff"],
			"time_of_day": "dusk",
			"light_direction": Vector2(-0.7, -0.6),
			"music_track": "res://assets/audio/music/Gathering at the Gates.wav",
			"elder_name": "Shuham",
			"elder_sprite": "res://assets/sprites/elders/elder_dan.svg",
			"elder_skin": "skin_medium",
			"elder_greeting": "My child, shalom. The sea has wisdom — it never rushes, yet it shapes every stone.",
			"character_pool": _char_pool_generic("dan"),
			"nature_sprites": [
				"res://assets/sprites/nature/eagle_soaring.svg",
				"res://assets/sprites/nature/fish_shoal.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/dan_sea_cliffs.svg",
			"quest_scene": "res://scenes/Quest5.tscn",
			"gem_color": Color(0.88, 0.56, 0.64), # agate / pink
			"gem_name": "Ligure",
			"verse_ref": "Psalm 46:10",
			"verse_text": "He says, 'Be still, and know that I am God.'",
			"nature_fact": "Dolphins use echolocation — they generate clicks and listen to the echo to navigate.",
		},

		# ── NAPHTALI – Harp Valleys ────────────────────────────────────────────
		# Genesis 49:21 – "Naphtali is a doe set free that bears beautiful fawns."
		# Geography: lush green valley, harp-shaped hills, waterfalls, abundant fruit
		"naphtali": {
			"tribe_key": "naphtali",
			"display_name": "Naphtali – Harp Valleys",
			"geography": "lush green valley, sparkling waterfall, almond and palm trees",
			"sky_top": Color(0.38, 0.66, 0.92),
			"sky_horizon": Color(0.80, 0.94, 0.72),
			"ground_color": Color(0.46, 0.64, 0.34),
			"accent_colors": [Color(0.22, 0.78, 0.68), Color(1.00, 0.84, 0.00)],
			"vegetation": ["almond blossom", "date palm", "trailing grapevine", "wild hyssop"],
			"terrain_features": ["waterfall cascade", "stone arch bridge", "basket-weave footpath"],
			"ambient_sounds": ["waterfall", "birdsong_lush", "harp_ambient"],
			"time_of_day": "late_morning",
			"light_direction": Vector2(0.4, -0.7),
			"music_track": "res://assets/audio/music/Gather the Tribes.wav",
			"elder_name": "Jahziel",
			"elder_sprite": "res://assets/sprites/elders/elder_naphtali.svg",
			"elder_skin": "skin_deep",
			"elder_greeting": "My child, shalom! The valley sings today — can you hear it?",
			"character_pool": _char_pool_generic("naphtali"),
			"nature_sprites": [
				"res://assets/sprites/nature/deer_doe.svg",
				"res://assets/sprites/nature/butterfly_colorful.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/naphtali_valley.svg",
			"quest_scene": "res://scenes/Quest6.tscn",
			"gem_color": Color(0.56, 0.28, 0.76), # amethyst
			"gem_name": "Agate",
			"verse_ref": "Isaiah 40:31",
			"verse_text": "But those who hope in the LORD will renew their strength. They will soar on wings like eagles.",
			"nature_fact": "Eagles can spot a rabbit from 3 km away — their eyes have two foveas for telescopic and wide vision.",
		},

		# ── GAD – Frontier Plains ─────────────────────────────────────────────
		# Genesis 49:19 – "Gad will be attacked by a band of raiders…"
		# Geography: wide open frontier plains, watchtower ruins, troop staging area
		"gad": {
			"tribe_key": "gad",
			"display_name": "Gad – Frontier Plains",
			"geography": "wide open scrubland plains, ancient watchtower, boundary stone markers",
			"sky_top": Color(0.54, 0.72, 0.94),
			"sky_horizon": Color(0.96, 0.88, 0.64),
			"ground_color": Color(0.68, 0.60, 0.42),
			"accent_colors": [Color(0.78, 0.60, 0.30), Color(0.46, 0.64, 0.34)],
			"vegetation": ["tall grasses", "thorny bramble hedge", "lone terebinth tree"],
			"terrain_features": ["boundary stone", "watchtower ruin", "dry stone wall", "dust road"],
			"ambient_sounds": ["prairie_wind", "hawk_cry", "distant_drum"],
			"time_of_day": "morning",
			"light_direction": Vector2(0.5, -0.7),
			"music_track": "res://assets/audio/music/Gathering at the Gates.wav",
			"elder_name": "Zephon",
			"elder_sprite": "res://assets/sprites/elders/elder_gad.svg",
			"elder_skin": "skin_tan",
			"elder_greeting": "My child, a guard who prays is stronger than one who only watches. Shalom.",
			"character_pool": _char_pool_generic("gad"),
			"nature_sprites": [
				"res://assets/sprites/nature/horse.svg",
				"res://assets/sprites/nature/hawk.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/gad_plains.svg",
			"quest_scene": "res://scenes/Quest7.tscn",
			"gem_color": Color(0.08, 0.72, 0.30), # jacinth / green
			"gem_name": "Amethyst",
			"verse_ref": "Deuteronomy 31:6",
			"verse_text": "Be strong and courageous. Do not be afraid or terrified … for the LORD your God goes with you.",
			"nature_fact": "A horse can sleep standing up, locking its knees — but needs to lie down for deep REM sleep.",
		},

		# ── ASHER – Olive Grove Coast ──────────────────────────────────────────
		# Genesis 49:20 – "Asher's food will be rich; he will provide delicacies fit for a king."
		# Geography: gentle coastal olive groves, oil press, sea breeze, golden afternoon
		"asher": {
			"tribe_key": "asher",
			"display_name": "Asher – Olive Grove",
			"geography": "gentle hillside olive grove, stone oil press, calm sea in distance",
			"sky_top": Color(0.44, 0.68, 0.92),
			"sky_horizon": Color(1.00, 0.88, 0.60),
			"ground_color": Color(0.66, 0.60, 0.40),
			"accent_colors": [Color(0.52, 0.58, 0.30), Color(1.00, 0.82, 0.14)],
			"vegetation": ["ancient olive trees (2 000 y/o)", "lavender border", "pomegranate hedge"],
			"terrain_features": ["stone oil press", "mossy well", "terrace walls", "basket of fresh bread"],
			"ambient_sounds": ["sea_breeze", "mill_stone", "bees_hum"],
			"time_of_day": "golden_hour",
			"light_direction": Vector2(-0.3, -0.7),
			"music_track": "res://assets/audio/music/Inspired by My Best.wav",
			"elder_name": "Imnah",
			"elder_sprite": "res://assets/sprites/elders/elder_asher.svg",
			"elder_skin": "skin_medium",
			"elder_greeting": "My child, shalom. Here — fresh bread and olive oil. You are welcome.",
			"character_pool": _char_pool_generic("asher"),
			"nature_sprites": [
				"res://assets/sprites/nature/bee.svg",
				"res://assets/sprites/nature/olive_branch.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/asher_olive_grove.svg",
			"quest_scene": "res://scenes/Quest8.tscn",
			"gem_color": Color(0.22, 0.78, 0.68), # beryl / seafoam
			"gem_name": "Beryl",
			"verse_ref": "Psalm 34:8",
			"verse_text": "Taste and see that the LORD is good; blessed is the one who takes refuge in him.",
			"nature_fact": "Olive trees can live over 2 000 years — the trees in Gethsemane may have seen the time of kings.",
		},

		# ── ISSACHAR – Stargazing Fields ─────────────────────────────────────
		# 1 Chronicles 12:32 – "understood the times and knew what Israel should do"
		# Geography: open field, sunset → night sky, wheat rows, calendar standing stones
		"issachar": {
			"tribe_key": "issachar",
			"display_name": "Issachar – Harvest Fields",
			"geography": "flat harvest fields under a vast sky, standing stones, fire beacon",
			"sky_top": Color(0.10, 0.08, 0.26), # deep night
			"sky_horizon": Color(0.88, 0.50, 0.28), # last sunset glow
			"ground_color": Color(0.62, 0.56, 0.36),
			"accent_colors": [Color(0.96, 0.92, 0.68), Color(1.00, 0.70, 0.12)],
			"vegetation": ["ripe wheat rows", "barley bundles", "midnight hyssop"],
			"terrain_features": ["standing stone calendar", "fire beacon platform", "threshing floor"],
			"ambient_sounds": ["cricket_night", "wind_wheat", "fire_crackle"],
			"time_of_day": "dusk",
			"light_direction": Vector2(-0.5, -0.4),
			"music_track": "res://assets/audio/music/Gather the Tribes.wav",
			"elder_name": "Tola",
			"elder_sprite": "res://assets/sprites/elders/elder_issachar.svg",
			"elder_skin": "skin_light",
			"elder_greeting": "My child, shalom. Look up — the stars have told the seasons since before your grandfather's grandfather.",
			"character_pool": _char_pool_generic("issachar"),
			"nature_sprites": [
				"res://assets/sprites/nature/firefly.svg",
				"res://assets/sprites/nature/owl.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/issachar_fields.svg",
			"quest_scene": "res://scenes/Quest9.tscn",
			"gem_color": Color(0.88, 0.62, 0.14), # topaz / amber
			"gem_name": "Jacinth",
			"verse_ref": "Genesis 1:14",
			"verse_text": "And God said, 'Let there be lights in the vault of the sky to separate the day from the night, and let them serve as signs to mark sacred times.'",
			"nature_fact": "Fireflies produce cold light — their bioluminescence is 100% efficient with almost no heat wasted.",
		},

		# ── ZEBULUN – Harbour ──────────────────────────────────────────────────
		# Genesis 49:13 – "Zebulun will live by the seashore…"
		# Geography: lively harbour, fishing boats, market stalls, blue-and-white tiles
		"zebulun": {
			"tribe_key": "zebulun",
			"display_name": "Zebulun – Harbour Market",
			"geography": "Mediterranean harbour, colourful fishing boats, spice market, mosaic tiles",
			"sky_top": Color(0.30, 0.58, 0.92),
			"sky_horizon": Color(0.90, 0.88, 0.96),
			"ground_color": Color(0.74, 0.70, 0.60), # sandstone quay
			"accent_colors": [Color(0.24, 0.52, 0.92), Color(0.96, 0.92, 0.68), Color(0.88, 0.20, 0.20)],
			"vegetation": ["harbour tamarisk", "potted geraniums", "sea-fennel"],
			"terrain_features": ["stone quay", "fishing nets on posts", "spice-market stalls", "mosaic path"],
			"ambient_sounds": ["harbour_bustle", "seagull", "tackle_clink"],
			"time_of_day": "late_morning",
			"light_direction": Vector2(0.3, -0.8),
			"music_track": "res://assets/audio/music/Gathering at the Gates.wav",
			"elder_name": "Sered",
			"elder_sprite": "res://assets/sprites/elders/elder_zebulun.svg",
			"elder_skin": "skin_pale",
			"elder_greeting": "My child, shalom! Every ship in this harbour has a story — so do you.",
			"character_pool": _char_pool_generic("zebulun"),
			"nature_sprites": [
				"res://assets/sprites/nature/fish_shoal.svg",
				"res://assets/sprites/nature/seagull.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/zebulun_harbour.svg",
			"quest_scene": "res://scenes/Quest10.tscn",
			"gem_color": Color(0.14, 0.22, 0.16), # onyx
			"gem_name": "Onyx",
			"verse_ref": "Matthew 4:19",
			"verse_text": "'Come, follow me,' Jesus said, 'and I will send you out to fish for people.'",
			"nature_fact": "Honeybee scouts dance in a figure-eight to tell the hive the direction and distance of flowers — up to 5 km away.",
		},

		# ── JOSEPH – Fruitful Double Portion ─────────────────────────────────
		# Genesis 49:22 – "Joseph is a fruitful vine near a spring…"
		# Geography: abundant terraced orchard, twin waterfalls (Ephraim + Manasseh), rainbow mist
		"joseph": {
			"tribe_key": "joseph",
			"display_name": "Joseph – Fruitful Terraces",
			"geography": "lush terraced orchards, twin waterfalls, rainbow mist, date palms",
			"sky_top": Color(0.36, 0.64, 0.94),
			"sky_horizon": Color(0.82, 0.96, 0.78),
			"ground_color": Color(0.46, 0.62, 0.32),
			"accent_colors": [Color(1.00, 0.84, 0.00), Color(0.22, 0.78, 0.68), Color(0.88, 0.12, 0.18)],
			"vegetation": ["fig tree", "pomegranate heavy with fruit", "date palm avenue", "grapevine pergola"],
			"terrain_features": ["terrace walls", "twin waterfall mouth", "ancient granary", "rainbow mist pool"],
			"ambient_sounds": ["waterfall_twin", "birds_tropical", "wind_chimes"],
			"time_of_day": "morning",
			"light_direction": Vector2(0.5, -0.7),
			"music_track": "res://assets/audio/music/Inspired by My Best.wav",
			"elder_name": "Beriah",
			"elder_sprite": "res://assets/sprites/elders/elder_joseph.svg",
			"elder_skin": "skin_medium",
			"elder_greeting": "My child, God turns every hardship into harvest. Shalom — look how the vines are full today!",
			"character_pool": _char_pool_generic("joseph"),
			"nature_sprites": [
				"res://assets/sprites/nature/butterfly_colorful.svg",
				"res://assets/sprites/nature/hummingbird.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/joseph_terraces.svg",
			"quest_scene": "res://scenes/Quest11.tscn",
			"gem_color": Color(0.08, 0.72, 0.30), # jasper / green
			"gem_name": "Jasper",
			"verse_ref": "Genesis 50:20",
			"verse_text": "You intended to harm me, but God intended it for good to accomplish what is now being done.",
			"nature_fact": "Fig trees feed more species of wildlife than almost any other tree — over 1 200 species eat figs worldwide.",
		},

		# ── BENJAMIN – Wolf Den at Dawn ───────────────────────────────────────
		# Genesis 49:27 – "Benjamin is a ravenous wolf…"
		# Geography: dense hill forest at first light, wolf tracks, hidden watchtower
		"benjamin": {
			"tribe_key": "benjamin",
			"display_name": "Benjamin – Wolf Hills",
			"geography": "forested hilltop, cedar and oak, wolf tracks in soft earth, dawn mist",
			"sky_top": Color(0.26, 0.40, 0.72),
			"sky_horizon": Color(0.98, 0.72, 0.44),
			"ground_color": Color(0.48, 0.42, 0.30), # forest floor
			"accent_colors": [Color(0.52, 0.72, 0.28), Color(0.92, 0.68, 0.28)],
			"vegetation": ["towering oak", "cedar canopy", "fern undergrowth", "wild anemone"],
			"terrain_features": ["wolf-paw prints path", "hidden watchtower nook", "mossy ruins", "dawn mist pools"],
			"ambient_sounds": ["wolf_howl_distant", "forest_dawn", "owl_depart"],
			"time_of_day": "dawn",
			"light_direction": Vector2(0.7, -0.6),
			"music_track": "res://assets/audio/music/Lion of the Dawn.wav",
			"elder_name": "Bela",
			"elder_sprite": "res://assets/sprites/elders/elder_benjamin.svg",
			"elder_skin": "skin_tan",
			"elder_greeting": "My child, even the wolf learns patience by sunrise. Good morning — shalom.",
			"character_pool": _char_pool_generic("benjamin"),
			"nature_sprites": [
				"res://assets/sprites/nature/wolf.svg",
				"res://assets/sprites/nature/owl.svg",
			],
			"bg_sprite": "res://assets/sprites/backgrounds/benjamin_forest.svg",
			"quest_scene": "res://scenes/Quest12.tscn",
			"gem_color": Color(0.14, 0.12, 0.16), # onyx / black
			"gem_name": "Jasper",
			"verse_ref": "Romans 8:28",
			"verse_text": "And we know that in all things God works for the good of those who love him.",
			"nature_fact": "Wolves howl to communicate over distances of up to 10 km — each wolf's howl is unique, like a fingerprint.",
		},
	}


# ─────────────────────────────────────────────────────────────────────────────
# spawn_characters(tribe_key, count) → Array[Dictionary]
# Returns NPC placement data for the tribe zone.
# Each dict: { sprite, position, flip, skin, name, age }
# "God sees not as man sees" – 1 Samuel 16:7
# ─────────────────────────────────────────────────────────────────────────────
static func spawn_characters(tribe_key: String, count: int) -> Array:
	var pool: Array = zone(tribe_key).get("character_pool", [])
	if pool.is_empty():
		return []
	var result: Array = []
	for i in range(min(count, pool.size())):
		var c: Dictionary = pool[i].duplicate()
		# Spread across lower third of scene
		c["position"] = Vector2(120 + i * 160, 520 + (i % 2) * 40)
		c["flip"] = (i % 3 == 0)
		result.append(c)
	return result


# ─────────────────────────────────────────────────────────────────────────────
# scene_composition(tribe_key) → Dictionary
# Returns placement hints for elder, focal child, and background depth.
# Derived from group reference images that show natural human compositions.
# ─────────────────────────────────────────────────────────────────────────────
static func scene_composition(tribe_key: String) -> Dictionary:
	return {
		"elder_pos": Vector2(140, 460), # left side, anchored
		"child_pos": Vector2(500, 500), # centre-right, slightly lower
		"focus_item": Vector2(320, 440), # gem / scroll focal point
		"crowd_spread": Rect2(80, 500, 640, 120),
		"sky_rect": Rect2(0, 0, 720, 280),
		"ground_rect": Rect2(0, 280, 720, 200),
	}


# ─────────────────────────────────────────────────────────────────────────────
# lighting_profile(time_of_day) → Dictionary
# 7 profiles drawn from reference image lighting analysis.
# All values stay warm — no cold whites or harsh blues.
# "The light shines in the darkness" – John 1:5
# ─────────────────────────────────────────────────────────────────────────────
static func lighting_profile(time_of_day: String) -> Dictionary:
	match time_of_day:
		"dawn":
			return {
				"ambient": Color(0.98, 0.80, 0.62),
				"sun_color": Color(1.00, 0.78, 0.44),
				"sun_angle": -15.0, # degrees from horizon
				"shadow_soft": true,
				"fog_color": Color(0.98, 0.88, 0.72, 0.18),
				"post_bloom": 0.15,
			}
		"morning":
			return {
				"ambient": Color(0.96, 0.92, 0.80),
				"sun_color": Color(1.00, 0.96, 0.80),
				"sun_angle": 30.0,
				"shadow_soft": false,
				"fog_color": Color(0.92, 0.92, 0.88, 0.06),
				"post_bloom": 0.08,
			}
		"late_morning":
			return {
				"ambient": Color(0.94, 0.92, 0.82),
				"sun_color": Color(1.00, 0.98, 0.88),
				"sun_angle": 50.0,
				"shadow_soft": false,
				"fog_color": Color(0.96, 0.96, 0.92, 0.04),
				"post_bloom": 0.05,
			}
		"midday":
			return {
				"ambient": Color(0.90, 0.88, 0.78),
				"sun_color": Color(1.00, 0.98, 0.90),
				"sun_angle": 88.0,
				"shadow_soft": false,
				"fog_color": Color(0.96, 0.96, 0.94, 0.03),
				"post_bloom": 0.04,
			}
		"golden_hour":
			return {
				"ambient": Color(0.98, 0.84, 0.52),
				"sun_color": Color(1.00, 0.72, 0.28),
				"sun_angle": 12.0,
				"shadow_soft": true,
				"fog_color": Color(0.98, 0.82, 0.50, 0.12),
				"post_bloom": 0.22,
			}
		"dusk":
			return {
				"ambient": Color(0.88, 0.62, 0.40),
				"sun_color": Color(0.96, 0.46, 0.20),
				"sun_angle": -8.0,
				"shadow_soft": true,
				"fog_color": Color(0.80, 0.44, 0.28, 0.20),
				"post_bloom": 0.28,
			}
		"interior_lamp": # Levi cedar hall – 7-flame lampstand
			return {
				"ambient": Color(0.82, 0.66, 0.38),
				"sun_color": Color(1.00, 0.80, 0.36),
				"sun_angle": 90.0, # overhead lampstand
				"shadow_soft": true,
				"fog_color": Color(0.88, 0.72, 0.42, 0.10),
				"post_bloom": 0.30,
			}
		_:
			return lighting_profile("morning")


# ─────────────────────────────────────────────────────────────────────────────
# elder_greeting(tribe_key, player_name) → String
# Personalised dialogue line.  Always "My child" opening, always "shalom".
# "A gentle answer turns away wrath" – Proverbs 15:1
# ─────────────────────────────────────────────────────────────────────────────
static func elder_greeting(tribe_key: String, player_name: String) -> String:
	var z: Dictionary = zone(tribe_key)
	var base: String = z.get("elder_greeting", "My child, shalom.")
	if player_name != "":
		base = base.replace("My child", "My child " + player_name)
	return base


# ─────────────────────────────────────────────────────────────────────────────
# music_for(context) → String   (res:// path)
# Maps game context keys to actual WAV files in assets/audio/music/.
# ─────────────────────────────────────────────────────────────────────────────
static func music_for(context: String) -> String:
	match context:
		"main_menu", "title":
			return "res://assets/audio/music/Gather the Tribes.wav"
		"lobby", "avatar_pick":
			return "res://assets/audio/music/Gathering at the Gates.wav"
		"levi", "prayer", "scroll":
			return "res://assets/audio/music/Incense in the Vaulted Air.wav"
		"judah", "finale", "celebration", "lion":
			return "res://assets/audio/music/Lion of the Dawn.wav"
		"asher", "joseph", "naphtali", "abundant":
			return "res://assets/audio/music/Inspired by My Best.wav"
		"reuben", "benjamin", "simeon", "dawn":
			return "res://assets/audio/music/Lion of the Dawn.wav"
		"dan", "zebulun", "gad", "sea":
			return "res://assets/audio/music/Gathering at the Gates.wav"
		"issachar", "verse_vault":
			return "res://assets/audio/music/Gather the Tribes.wav"
		_:
			return "res://assets/audio/music/Gather the Tribes.wav"


# ─────────────────────────────────────────────────────────────────────────────
# sfx_ui_open() → String
# The one-shot UI open sound.
# ─────────────────────────────────────────────────────────────────────────────
static func sfx_ui_open() -> String:
	return "res://assets/audio/sfx/ui_open.wav"

# ─────────────────────────────────────────────────────────────────────────────
# REFERENCE_ART — catalogue of all organized reference images.
# These drove every colour, character, and lighting decision above.
# ─────────────────────────────────────────────────────────────────────────────
const REFERENCE_ART := {
	"originals": [
		"res://assets/reference_art/batch_originals/original_c0112e1e.jpg",
		"res://assets/reference_art/batch_originals/original_3ec225d0.jpg",
		"res://assets/reference_art/batch_originals/original_2adf0f7f.jpg",
		"res://assets/reference_art/batch_originals/original_19c97e69.jpg",
	],
	# 40 character portraits — diverse ages (12–29), skin, hair, eyes
	"characters": [
		"res://assets/reference_art/characters/char_001.jpg",
		"res://assets/reference_art/characters/char_002.jpg",
		"res://assets/reference_art/characters/char_003.jpg",
		"res://assets/reference_art/characters/char_004.jpg",
		"res://assets/reference_art/characters/char_005.jpg",
		"res://assets/reference_art/characters/char_006.jpg",
		"res://assets/reference_art/characters/char_007.jpg",
		"res://assets/reference_art/characters/char_008.jpg",
		"res://assets/reference_art/characters/char_009.jpg",
		"res://assets/reference_art/characters/char_010.jpg",
		"res://assets/reference_art/characters/char_011.jpg",
		"res://assets/reference_art/characters/char_012.jpg",
		"res://assets/reference_art/characters/char_013.jpg",
		"res://assets/reference_art/characters/char_014.jpg",
		"res://assets/reference_art/characters/char_015.jpg",
		"res://assets/reference_art/characters/char_016.jpg",
		"res://assets/reference_art/characters/char_017.jpg",
		"res://assets/reference_art/characters/char_018.jpg",
		"res://assets/reference_art/characters/char_019.jpg",
		"res://assets/reference_art/characters/char_020.jpg",
		"res://assets/reference_art/characters/char_021.jpg",
		"res://assets/reference_art/characters/char_022.jpg",
		"res://assets/reference_art/characters/char_023.jpg",
		"res://assets/reference_art/characters/char_024.jpg",
		"res://assets/reference_art/characters/char_025.jpg",
		"res://assets/reference_art/characters/char_026.jpg",
		"res://assets/reference_art/characters/char_027.jpg",
		"res://assets/reference_art/characters/char_028.jpg",
		"res://assets/reference_art/characters/char_029.jpg",
		"res://assets/reference_art/characters/char_030.jpg",
		"res://assets/reference_art/characters/char_031.jpg",
		"res://assets/reference_art/characters/char_032.jpg",
		"res://assets/reference_art/characters/char_033.jpg",
		"res://assets/reference_art/characters/char_034.jpg",
		"res://assets/reference_art/characters/char_035.jpg",
		"res://assets/reference_art/characters/char_036.jpg",
		"res://assets/reference_art/characters/char_037.jpg",
		"res://assets/reference_art/characters/char_038.jpg",
		"res://assets/reference_art/characters/char_039.jpg",
		"res://assets/reference_art/characters/char_040.jpg",
	],
	# 11 group compositions — multiple characters, scene staging, crowd dynamics
	"groups": [
		"res://assets/reference_art/groups/group_001.jpg",
		"res://assets/reference_art/groups/group_002.jpg",
		"res://assets/reference_art/groups/group_003.jpg",
		"res://assets/reference_art/groups/group_004.jpg",
		"res://assets/reference_art/groups/group_005.jpg",
		"res://assets/reference_art/groups/group_006.jpg",
		"res://assets/reference_art/groups/group_007.jpg",
		"res://assets/reference_art/groups/group_008.jpg",
		"res://assets/reference_art/groups/group_009.jpg",
		"res://assets/reference_art/groups/group_010.jpg",
		"res://assets/reference_art/groups/group_011.jpg",
	],
	# 2 environment scenes — 960×960 wide establishing shots
	"scenes": [
		"res://assets/reference_art/scenes/scene_001.jpg",
		"res://assets/reference_art/scenes/scene_002.jpg",
	],
}


# ─────────────────────────────────────────────────────────────────────────────
# Private helpers — character pools
# Each pool has 4 NPCs: varied skin, hair, age (12–29), with short roles.
# No avatar is ever a clone — Gen 1:27 (every person made in God's image)
# ─────────────────────────────────────────────────────────────────────────────
static func _char_pool_reuben() -> Array:
	return [
		{
			"sprite": "res://assets/sprites/characters/child_f_dark.svg",
			"skin": "skin_deep",
			"hair": "hair_black",
			"age": 14,
			"role": "cliff-scout",
		},
		{
			"sprite": "res://assets/sprites/characters/child_m_medium.svg",
			"skin": "skin_medium",
			"hair": "hair_auburn",
			"age": 17,
			"role": "stream-keeper",
		},
		{
			"sprite": "res://assets/sprites/characters/child_f_light.svg",
			"skin": "skin_light",
			"hair": "hair_golden",
			"age": 12,
			"role": "butterfly-watcher",
		},
		{
			"sprite": "res://assets/sprites/characters/child_m_tan.svg",
			"skin": "skin_tan",
			"hair": "hair_dark_brown",
			"age": 19,
			"role": "cave-mapper",
		},
	]


static func _char_pool_generic(tribe: String) -> Array:
	# Returns a diversified 4-person pool for any tribe.
	# Skin/hair assignments cycle to ensure variety across 12 tribes.
	var skins := ["skin_pale", "skin_light", "skin_medium", "skin_tan", "skin_brown", "skin_deep"]
	var hairs := ["hair_black", "hair_dark_brown", "hair_auburn", "hair_golden", "hair_silver"]
	var ages := [12, 14, 16, 18, 21, 24, 29]
	var seed_val := tribe.hash()
	var pool: Array = []
	for i in range(4):
		var si: int = (seed_val + i * 7 + i) % skins.size()
		var hi: int = (seed_val + i * 3 + 2) % hairs.size()
		var ai: int = (seed_val + i * 5 + 1) % ages.size()
		pool.append(
			{
				"sprite": "res://assets/sprites/characters/child_f_medium.svg",
				"skin": skins[si],
				"hair": hairs[hi],
				"age": ages[ai],
				"role": tribe + "_helper_" + str(i + 1),
			},
		)
	return pool
