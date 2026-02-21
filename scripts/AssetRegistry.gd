extends Node

# ─────────────────────────────────────────────────────────────────────────────
# AssetRegistry.gd  –  Twelve Stones / Ephod Quest
# Central catalog for ALL 149 UUID textures, 35 artworks, audio tracks.
#
# Usage:
#   AssetRegistry.terrain("grass")   → "res://assets/textures/<uuid>.jpg"
#   AssetRegistry.wall("gold")       → "res://assets/textures/<uuid>.jpg"
#   AssetRegistry.prop("tree")       → "res://assets/textures/<uuid>.jpg"
#   AssetRegistry.char_tex("skin")   → "res://assets/textures/<uuid>.jpg"
#   AssetRegistry.artwork(index)     → "res://assets/sprites/raw/img_XX.jpg"
#   AssetRegistry.music(tribe)       → "res://assets/audio/music/xxx.wav"
#   AssetRegistry.sfx(key)           → "res://assets/audio/sfx/xxx.wav"
#   AssetRegistry.tribe_terrain(key) → best terrain texture for the tribe
#   AssetRegistry.tribe_wall(key)    → best wall texture for the tribe
#
# "He set the earth on its foundations; it can never be moved." – Psalm 104:5
# ─────────────────────────────────────────────────────────────────────────────

const _BASE := "res://assets/textures/"
const _SPR := "res://assets/sprites/raw/"
const _MUS := "res://assets/audio/music/"
const _SFX := "res://assets/audio/sfx/"

# ─────────────────────────────────────────────────────────────────────────────
# TERRAIN TEXTURES (ground plane surfaces)
# Indices 0–11: grass varieties  |  12–23: dirt / earth  |  24–35: stone
# 36–47: sand / desert  |  48–55: water / wet ground
# ─────────────────────────────────────────────────────────────────────────────
const TERRAIN: Dictionary = {
	# Grass – lush greens for fertile lands (Asher, Joseph, Naphtali, Gad)
	"grass": "0377e22c-a7e1-4788-868f-996abde03a20.jpg",
	"grass_dark": "04cdeab6-1cff-47d1-8b51-3f7b8a95f0c5.jpg",
	"grass_light": "06334dbc-408d-4d74-a5ea-fe6299ce427d.jpg",
	"grass_dry": "0691f509-4336-4efe-95d6-bb822005879a.jpg",
	"grass_moss": "07d788d9-81bd-464f-9a80-745021c22aac.jpg",
	"grass_field": "080e42d5-4ef2-4f9c-823f-1ea34c9bda4d.jpg",
	"meadow": "09c66e53-3482-4824-89fe-d3a4e1efd90b.jpg",
	"meadow_gold": "09d78d51-7a40-40bb-9bcd-676025973064.jpg",
	"turf": "0be4ea0d-7866-4d24-81f0-74a61462408f.jpg",
	"straw": "0de976ab-76d8-4684-9794-3324c6a063e7.jpg",
	"hay": "132bd291-a35e-46c0-845b-0813f5dcc7ba.jpg",
	"pasture": "15d784c1-b106-415f-8c59-5db87efa7486.jpg",

	# Dirt – warm earth for Reuben cliffs, Simeon desert, Issachar plains
	"dirt": "16b15e22-9fda-4eed-b7d0-8724c442d02c.jpg",
	"dirt_red": "19e78a7c-138d-4b86-b58a-7e6adb85d373.jpg",
	"dirt_clay": "1cbeba87-66fb-47a9-b03c-edbf94100cf5.jpg",
	"dirt_dark": "20f98d68-24a1-4ac8-875f-7584ee56fa5d.jpg",
	"earth": "21def437-9a84-4136-9993-d77c8efa6808.jpg",
	"earth_rich": "2489783d-c67a-477b-9eb7-851af4e34388.jpg",
	"loam": "2853a7c8-f058-46c6-82e1-193a8240066d.jpg",
	"mud": "28b684ec-ab25-471e-b9fa-11da625ebde5.jpg",
	"gravel": "29f22758-076b-4fc1-a9d6-96fa6220bab7.jpg",
	"pebble": "2dd4b5b4-eeb8-445f-abaa-6c509eac224f.jpg",
	"rubble": "2e7989c0-2c9c-4683-b6d9-95893073b2d6.jpg",
	"soil": "3214548f-f6b7-49d8-9be8-fd15165c6fd8.jpg",

	# Stone – pavements, ancient streets (Levi sacred hall, finales)
	"stone": "34b41359-23ed-49aa-aafd-8ffa0553507a.jpg",
	"stone_grey": "3822db09-da73-4536-acc3-b116146919ac.jpg",
	"stone_dark": "3a0a5021-1154-455f-94dc-27e05b6b6de3.jpg",
	"cobble": "3a738157-c18a-42f0-89ca-2055aa8c1461.jpg",
	"flagstone": "3b3fbcb8-1f1f-46aa-8f6e-c8a8784fbd7e.jpg",
	"mosaic": "3b639f2b-6f30-4377-927a-0e8a2f58206a.jpg",
	"slate": "4344eb15-92e2-4050-911c-20ae0194496e.jpg",
	"limestone": "44870172-3857-4bf2-bd36-2a18047b4285.jpg",
	"sandstone": "458c062e-3a51-4b39-8484-46a59be44069.jpg",
	"marble": "45aa2006-03e1-44c2-85d6-6535d415b19d.jpg",
	"basalt": "4837287e-6485-445a-9205-799e0ac26328.jpg",
	"granite": "4874741f-78c1-4382-9fec-5fb98b5ecc39.jpg",

	# Sand – pale golden desert (Simeon, Dan coast, Benjamin dunes)
	"sand": "4923ada3-bacd-4cd5-a52d-e19ac4817cc0.jpg",
	"sand_fine": "4c07e5fb-7f4b-4d13-80e6-dd34f130c0cb.jpg",
	"sand_dune": "4c0c823e-15e2-4e48-a78e-886523ab9d5a.jpg",
	"sand_wet": "4da93c59-0009-445a-8f2d-3177798785d4.jpg",
	"sand_red": "502bed4d-5a30-4e1b-b5a8-77640cbd4e0d.jpg",
	"dunes": "5359e35b-31e0-4435-abdc-5c15209d2ecb.jpg",
	"silt": "587e77d8-cf0f-4c28-823e-3aefccf1c2d0.jpg",
	"desert": "5fa2ea96-737e-427a-aed2-8723dbe3dc30.jpg",
	"desert_hard": "5fc38d6c-c3cd-445f-a3fd-a2e03852fff1.jpg",
	"salt_flat": "61e94bc9-3bb1-4efb-b28a-d18a9ddfa3f6.jpg",
	"gravel_sand": "623c04f2-aab5-4c3b-ad57-fb9bdd9f5e1a.jpg",
	"pale_earth": "62ac0003-6e9f-4cda-9a0b-0133ac91f444.jpg",

	# Water / wet – Zebulun harbour, Dan coast, streams
	"water": "635d03e0-46ba-4cb4-875a-6e6dbb2e3331.jpg",
	"water_dark": "6539c507-514f-453c-8ac3-3adbcc91e061.jpg",
	"water_shore": "6716d5a5-b00d-449f-932b-3f2a68ee5860.jpg",
	"river_bed": "696a2113-bd86-4744-9802-455b598daf3c.jpg",
	"tide_pool": "6a579585-a869-4cfe-95b3-b1c4ae398cb3.jpg",
	"marsh": "6a7ff27b-095b-4aff-b7c2-821963b84bd8.jpg",
	"sea_foam": "6c2a7dea-b2e8-4fe1-93b8-13f7823d9413.jpg",
	"lake_floor": "6f3f6acd-5d13-4f16-b9f3-8f80fc9d3f5c.jpg",
}

# ─────────────────────────────────────────────────────────────────────────────
# WALL / SURFACE TEXTURES (vertical faces, structural elements)
# ─────────────────────────────────────────────────────────────────────────────
const WALL: Dictionary = {
	# Rock / cliff faces
	"rock": "72133778-88a2-4666-a200-50764ff2158e.jpg",
	"rock_rough": "72150459-8ee1-4bc6-9248-789c2323ead5.jpg",
	"rock_dark": "7525c64a-646a-4b4b-8660-2424e0c02084.jpg",
	"cliff": "755e53f5-bda7-4429-8147-4b1140ef95cd.jpg",
	"cliff_red": "756dac0d-b5ce-4a37-b61f-ea01fdefd438.jpg",
	"cliff_pale": "75f991ff-1a57-430e-9051-d5d7a8683b22.jpg",
	"cave_wall": "762824d6-765d-429f-9906-997820231ce3.jpg",
	"canyon": "76caac9d-96d0-432d-afc0-20b5b33c2cc2.jpg",
	"boulder": "77ccdfa4-9868-4867-b47d-494a5f25a101.jpg",
	"brick": "7889d47c-d8bb-4229-a6e9-ed911575f509.jpg",
	"stone_wall": "7a9b33e2-6f44-46d9-99ff-43bcb42f8a3b.jpg",
	"ashlar": "7ab9d6ed-a05e-48f5-9296-d71560c76866.jpg",

	# Wood / cedar – structural beams, doors, fences
	# "He built the inner sanctuary… with beams of cedar" – 1 Kings 6:15
	"wood": "7d8c0e24-4695-4c83-b6f6-276c9a2dd2c7.jpg",
	"wood_dark": "806ec5a9-6808-42ce-bba2-6c8a33a77869.jpg",
	"cedar": "813f2c7b-83f1-4420-8278-c8168d294cad.jpg",
	"cedar_plank": "81b9b0aa-1285-42c3-9ca6-d0d5612ee8bf.jpg",
	"log": "82b49588-3367-4cf0-9cd4-3e1c4720cfea.jpg",
	"bark": "838ffcf6-c2a1-4a64-8c0c-18fbf620fb62.jpg",
	"timber": "8986e231-2b19-48dd-bcb3-2100ec77ffd6.jpg",
	"twig": "8a0c98b7-9042-49a0-a8f0-bc5cf281be55.jpg",
	"woven_wood": "8a60ecda-1a42-4dd0-81c5-008cd304ead8.jpg",
	"olive_wood": "8ae65a66-d56b-41cd-89f3-3a40c84cc8fd.jpg",

	# Gold / precious surfaces – ephod pillars, altar, holy items
	# "Overlay it with pure gold" – Exodus 25:11
	"gold": "8bacff20-f5fa-401e-b403-77de652026cb.jpg",
	"gold_leaf": "8d67181a-ddd4-44e4-bd0a-69d009e8fcdc.jpg",
	"gold_plate": "8f5c5db4-b13d-4eb8-b00d-c8dfa8f17597.jpg",
	"brass": "900417eb-f00b-48e6-b24d-6d9d65c0ee67.jpg",
	"bronze": "9139df6a-2194-43dc-a5ff-a9fd6b631fee.jpg",
	"silver": "9367a5f1-b95d-4358-aab7-f581fdf24e8d.jpg",
	"copper": "9427cb77-9330-4f34-aeb8-cff950a573a2.jpg",
	"ivory": "975b52de-e564-498e-9c9e-6ac42b04b544.jpg",

	# Cedar / carved interior beams
	"carved_beam": "988af909-4d63-4d3a-9a9b-a39799b82006.jpg",
	"carved_panel": "9eae62fc-8e81-46de-99da-5658ce60d185.jpg",
	"linen_weave": "a14af7cc-d833-4bff-8ad9-4561de6ba6b9.jpg",
	"silk_blue": "a17ff640-dcd2-4c85-b907-7d577b721251.jpg",
	"scarlet": "a4bb36a0-7187-45d8-9248-d628de224750.jpg",
	"purple_cloth": "a75bb7d0-d938-40da-9ab3-69f8d52461c7.jpg",
	"tent_canvas": "a87b8d94-b771-4d50-90b5-ba10bf5f10b3.jpg",
	"hide": "a8b05b53-9272-483f-88f8-a5015434c53e.jpg",
}

# ─────────────────────────────────────────────────────────────────────────────
# PROP TEXTURES (environmental objects, foliage, decorative items)
# ─────────────────────────────────────────────────────────────────────────────
const PROP: Dictionary = {
	# Tree foliage and bark
	"tree_leaf": "aa01fcee-9f0a-4037-b923-b8aebd6b73c9.jpg",
	"tree_bark": "add0e085-40ad-48cc-bc6c-d5542c9a0baf.jpg",
	"tree_pine": "aec4fad1-fc78-44db-ab2f-d337ed65e9c8.jpg",
	"tree_olive": "afdb59af-d307-4def-baf5-6d997b6949d9.jpg",
	"tree_palm": "afe98d7b-68ad-4e1a-ab78-0cfe66cf1bac.jpg",
	"tree_fruit": "b14481c6-2e71-44c7-be9e-72e2b34e686f.jpg",
	"canopy": "b18404ea-b6c8-4aa5-bcec-f77a09a8dc76.jpg",
	"vine": "b45aa422-45f3-49bc-b503-d0a46bc6eb06.jpg",
	"fern": "b4a34123-6bc2-4747-b4d9-a5e4fe94646a.jpg",
	"reed": "b4f48ef9-b5c8-4050-9c85-aa9180891c73.jpg",

	# Bush and ground cover
	"bush": "b82c6f43-deac-49ca-8eba-00fbc42f89e1.jpg",
	"bush_flower": "b8f05ba5-b3ba-4a03-84d0-ab8a8f952751.jpg",
	"scrub": "bcb159b5-e231-4b76-add4-e444ebe6c9c5.jpg",
	"thistle": "be8b7901-6955-4bb3-a81b-1733f2b3b45f.jpg",
	"wheat": "c1be595d-2c94-4e28-ae38-cd0674a5b99c.jpg",
	"barley": "c41a6698-fc6e-4bb6-8b88-06843ebbafa0.jpg",
	"flower": "c446b499-f626-4f01-b8e7-14ca9826025a.jpg",
	"herb": "c5ff7e13-cc19-4eb7-ab69-b55454920a64.jpg",

	# Rocks and boulders (scattered props)
	"rock_prop": "ca0ed838-c55e-4477-b58a-79c0a16be004.jpg",
	"rock_smooth": "ca876f79-2af6-4be8-83ed-3e696295911f.jpg",
	"rock_pile": "cb0bd6ac-b597-48e6-a79d-401e13a5aa9d.jpg",
	"pebble_pile": "cb2e5883-53a6-4ea5-a38a-8640dd1883ab.jpg",
	"mossy_rock": "cbaf8b20-0856-4c22-b443-e72201b42d4b.jpg",
	"stepping_stone": "cf49ad4f-40ee-4cf6-a1bf-9dfea4464b3a.jpg",
	"buried_stone": "cfb78ce4-b9c8-4cd2-9205-61d7dbede98b.jpg",
	"stone_altar": "d2e548c9-b040-4166-ac66-3bcd844d6ad1.jpg",
}

# ─────────────────────────────────────────────────────────────────────────────
# CHARACTER TEXTURES (NPC and player body surfaces)
# ─────────────────────────────────────────────────────────────────────────────
const CHAR: Dictionary = {
	# Skin tones — diverse, warm, authentic
	# "God created mankind in his own image… male and female" – Genesis 1:27
	"skin_light": "d51eb3d3-abba-49c0-819c-b83c1fb8b830.jpg",
	"skin_medium": "d62f55ae-4de1-4d5d-8b36-7f54bea6a1bb.jpg",
	"skin_olive": "da5fe4d6-a4c9-4d5a-82e4-bc832116cb84.jpg",
	"skin_tan": "db2d7635-c2cc-4c49-8f94-f1e6bd1a3570.jpg",
	"skin_brown": "dc23b3f6-47b7-4396-9819-e00d9609a513.jpg",
	"skin_dark": "dd494276-632d-4fe2-9316-9c06d8ff154e.jpg",
	"skin_warm": "ddb42a94-f36b-41a0-ac14-ccebff6af130.jpg",
	"skin_deep": "ddfe9cf0-5a4b-452c-a5ac-467c7b6a7bc3.jpg",
	"face_young": "e154fc3b-7218-4df3-9ea1-ce0536a38939.jpg",
	"face_elder": "e4796d3a-97a9-4496-871b-8424524cd94d.jpg",
	"face_teen": "e702ff1a-64ec-4543-acd3-a2b4b074720a.jpg",
	"face_child": "e84e2301-9106-4288-9ce7-2e752657402d.jpg",

	# Robes, garments, tribal clothing
	# "Clothed in fine linen, purple and scarlet" – Revelation 18:16
	"robe_white": "e9820900-eb76-4daa-9e99-3b3cf0a1ee6e.jpg",
	"robe_blue": "ea5e2a2a-3bb7-4b7a-9907-1089a6ed28f0.jpg",
	"robe_red": "eae6a88c-fe34-43b2-b434-516bfeb6fa30.jpg",
	"robe_gold": "ec670b89-906b-4aa1-bd43-2c4fd5d60f17.jpg",
	"robe_purple": "edbe193e-aadd-4a88-929c-b1ab75bc6c05.jpg",
	"robe_green": "ef88bb1c-ad34-4bfa-87fe-eb453fce6794.jpg",
	"tunic_brown": "f0436449-1f65-450b-8edb-ad1941407ef9.jpg",
	"tunic_grey": "f0864cef-7117-4e38-a250-3b7a1b0871bd.jpg",
	"headwrap": "f1ca753b-beee-4101-9623-362493d017f4.jpg",
	"cloak": "f2eb9956-3dad-4b24-aa04-094fbced7010.jpg",
	"ephod_cloth": "f4449648-32f3-4d19-91b0-5e39bc407577.jpg",
	"linen_robe": "f620ce1a-55f7-4c2d-8cf3-33fdc6a36afb.jpg",

	# Glow / FX textures (used on gemstones, light shafts, halos)
	"glow_gold": "fa23b3e4-c0f2-4a1a-bced-906b358b9489.jpg",
	"glow_white": "fab30ea2-f873-4ce0-b61c-f29c8875bf1c.jpg",
	"glow_blue": "fae0096a-ae81-43c5-afe0-521bc03fb911.jpg",
	"glow_gem": "fb40b8c1-9edd-4029-81aa-dce5cd062961.jpg",
}

# ─────────────────────────────────────────────────────────────────────────────
# UI SPRITES  –  panel backgrounds, HUD elements, reference sheets
# All in res://assets/sprites/ui/
# ─────────────────────────────────────────────────────────────────────────────
const UI: Dictionary = {
	# Parchment panel background — used by dialogue panels and VerseVault cards
	# "Write them on the tablet of your heart" – Proverbs 3:3
	"panel_parchment": "res://assets/sprites/ui/panel_parchment.jpg",

	# All 12 ephod gemstones laid out in two rows — Exodus 28:17-20
	# Used by: WorldBase stone HUD, VerseVault header, Finale breastplate display
	"gems_reference_sheet": "res://assets/sprites/ui/gems_reference_sheet.jpg",

	# UI layout wireframe (SVG) — developer reference only
	"diagram": "res://assets/sprites/ui/diagram.svg",
}

# ─────────────────────────────────────────────────────────────────────────────
# VIDEO FILES  –  Grok AI-generated clips + audio visualisations
# Used by VideoStreamPlayer nodes (require FFMpeg GDExtension for MP4 on web)
# For native platforms MP4 plays directly via system codecs.
# "A time to weep and a time to laugh, a time to mourn and a time to dance" – Eccl 3:4
# ─────────────────────────────────────────────────────────────────────────────
const VIDEO: Dictionary = {
	# Intro splash — best quality (4.5 MB)
	"splash_intro": "res://assets/videos/5a95c472-bc3d-41cb-8ed9-ee41217f555e_hd.mp4",

	# Grok AI scene clips — tribal moments, celebrations, nature beauty
	"grok_clip_a": "res://assets/videos/grok-video-696a2113-bd86-4744-9802-455b598daf3c.mp4",
	"grok_clip_b": "res://assets/videos/grok-video-a17ff640-dcd2-4c85-b907-7d577b721251.mp4",
	"grok_clip_c": "res://assets/videos/grok-video-f620ce1a-55f7-4c2d-8cf3-33fdc6a36afb.mp4",

	# Audio visualisation loop (WebM/VP8 — web-safe)
	"audio_vis": "res://assets/videos/personaplex_audio.webm",
}

# ─────────────────────────────────────────────────────────────────────────────
# GEM SPRITES — faceted SVG gemstones, one per tribe (Exodus 28:17-20)
# "A ruby, a topaz and a beryl…" — Exodus 28:17
# ─────────────────────────────────────────────────────────────────────────────
const GEMS: Dictionary = {
	"reuben": "res://assets/sprites/gems/gem_reuben.svg",
	"simeon": "res://assets/sprites/gems/gem_simeon.svg",
	"levi": "res://assets/sprites/gems/gem_levi.svg",
	"judah": "res://assets/sprites/gems/gem_judah.svg",
	"dan": "res://assets/sprites/gems/gem_dan.svg",
	"naphtali": "res://assets/sprites/gems/gem_naphtali.svg",
	"gad": "res://assets/sprites/gems/gem_gad.svg",
	"asher": "res://assets/sprites/gems/gem_asher.svg",
	"issachar": "res://assets/sprites/gems/gem_issachar.svg",
	"zebulun": "res://assets/sprites/gems/gem_zebulun.svg",
	"joseph": "res://assets/sprites/gems/gem_joseph.svg",
	"benjamin": "res://assets/sprites/gems/gem_benjamin.svg",
}

# ─────────────────────────────────────────────────────────────────────────────
# ELDER PORTRAITS — cartoon NPC dialogue portraits, one per tribe
# "Grey hair is a crown of splendour" — Proverbs 16:31
# ─────────────────────────────────────────────────────────────────────────────
const ELDERS: Dictionary = {
	"reuben": "res://assets/sprites/elders/elder_reuben.svg",
	"simeon": "res://assets/sprites/elders/elder_simeon.svg",
	"levi": "res://assets/sprites/elders/elder_levi.svg",
	"judah": "res://assets/sprites/elders/elder_judah.svg",
	"dan": "res://assets/sprites/elders/elder_dan.svg",
	"naphtali": "res://assets/sprites/elders/elder_naphtali.svg",
	"gad": "res://assets/sprites/elders/elder_gad.svg",
	"asher": "res://assets/sprites/elders/elder_asher.svg",
	"issachar": "res://assets/sprites/elders/elder_issachar.svg",
	"zebulun": "res://assets/sprites/elders/elder_zebulun.svg",
	"joseph": "res://assets/sprites/elders/elder_joseph.svg",
	"benjamin": "res://assets/sprites/elders/elder_benjamin.svg",
}

# ─────────────────────────────────────────────────────────────────────────────
# NATURE ICONS — cartoon science/nature art for tribe facts
# "He speaks to them of trees…cedars to hyssop" — 1 Kings 4:33
# ─────────────────────────────────────────────────────────────────────────────
const NATURE: Dictionary = {
	"butterfly": "res://assets/sprites/nature/butterfly.svg",
	"eagle": "res://assets/sprites/nature/eagle.svg",
	"lion": "res://assets/sprites/nature/lion.svg",
	"deer": "res://assets/sprites/nature/deer.svg",
	"wolf": "res://assets/sprites/nature/wolf.svg",
	"sheep": "res://assets/sprites/nature/sheep.svg",
	"fish": "res://assets/sprites/nature/fish.svg",
	"olive_branch": "res://assets/sprites/nature/olive_branch.svg",
	"harp": "res://assets/sprites/nature/harp.svg",
	"star_scroll": "res://assets/sprites/nature/star_scroll.svg",
}

# ─────────────────────────────────────────────────────────────────────────────
# AVATAR SPRITES — diverse young cartoon characters (ages 12–29)
# 4 skin tones x 4 hair styles x 2 eye colors = 32 variants
# "I am fearfully and wonderfully made" — Psalm 139:14
# ─────────────────────────────────────────────────────────────────────────────
const AVATARS: Array = [
	"res://assets/sprites/avatars/avatar_light_black_curly_e1.svg",
	"res://assets/sprites/avatars/avatar_light_black_curly_e2.svg",
	"res://assets/sprites/avatars/avatar_light_brown_waves_e1.svg",
	"res://assets/sprites/avatars/avatar_light_brown_waves_e2.svg",
	"res://assets/sprites/avatars/avatar_light_gold_straight_e1.svg",
	"res://assets/sprites/avatars/avatar_light_gold_straight_e2.svg",
	"res://assets/sprites/avatars/avatar_light_dark_locs_e1.svg",
	"res://assets/sprites/avatars/avatar_light_dark_locs_e2.svg",
	"res://assets/sprites/avatars/avatar_medium_black_curly_e1.svg",
	"res://assets/sprites/avatars/avatar_medium_black_curly_e2.svg",
	"res://assets/sprites/avatars/avatar_medium_brown_waves_e1.svg",
	"res://assets/sprites/avatars/avatar_medium_brown_waves_e2.svg",
	"res://assets/sprites/avatars/avatar_medium_gold_straight_e1.svg",
	"res://assets/sprites/avatars/avatar_medium_gold_straight_e2.svg",
	"res://assets/sprites/avatars/avatar_medium_dark_locs_e1.svg",
	"res://assets/sprites/avatars/avatar_medium_dark_locs_e2.svg",
	"res://assets/sprites/avatars/avatar_olive_black_curly_e1.svg",
	"res://assets/sprites/avatars/avatar_olive_black_curly_e2.svg",
	"res://assets/sprites/avatars/avatar_olive_brown_waves_e1.svg",
	"res://assets/sprites/avatars/avatar_olive_brown_waves_e2.svg",
	"res://assets/sprites/avatars/avatar_olive_gold_straight_e1.svg",
	"res://assets/sprites/avatars/avatar_olive_gold_straight_e2.svg",
	"res://assets/sprites/avatars/avatar_olive_dark_locs_e1.svg",
	"res://assets/sprites/avatars/avatar_olive_dark_locs_e2.svg",
	"res://assets/sprites/avatars/avatar_deep_black_curly_e1.svg",
	"res://assets/sprites/avatars/avatar_deep_black_curly_e2.svg",
	"res://assets/sprites/avatars/avatar_deep_brown_waves_e1.svg",
	"res://assets/sprites/avatars/avatar_deep_brown_waves_e2.svg",
	"res://assets/sprites/avatars/avatar_deep_gold_straight_e1.svg",
	"res://assets/sprites/avatars/avatar_deep_gold_straight_e2.svg",
	"res://assets/sprites/avatars/avatar_deep_dark_locs_e1.svg",
	"res://assets/sprites/avatars/avatar_deep_dark_locs_e2.svg",
]

# ─────────────────────────────────────────────────────────────────────────────
# BACKGROUND SCENES — SVG scene illustrations
# ─────────────────────────────────────────────────────────────────────────────
const BACKGROUNDS: Dictionary = {
	"ephod_breastplate": "res://assets/sprites/backgrounds/ephod_breastplate.svg",
	"courtyard_pillars": "res://assets/sprites/backgrounds/courtyard_pillars.svg",
	"finale_assembly": "res://assets/sprites/backgrounds/finale_assembly.svg",
	# Reference-art scene backgrounds (from Grok concept art)
	"courtyard_warm": "res://assets/sprites/backgrounds/courtyard_warm.svg",
	"curtain_chamber": "res://assets/sprites/backgrounds/curtain_chamber.svg",
	"outdoor_ruins": "res://assets/sprites/backgrounds/outdoor_ruins.svg",
}

# ─────────────────────────────────────────────────────────────────────────────
# ARTWORK IMAGES (img_01 – img_35) — rendered scene paintings
# img_01–12  → tribe world backgrounds (Reuben–Benjamin, Exodus 28 order)
# img_13–17  → menu/UI scene backgrounds
# img_18–35  → character portraits, tools, environment details, holy items
# ─────────────────────────────────────────────────────────────────────────────
const ARTWORK: Array = [
	"", # [0] unused — 1-based index
	"res://assets/sprites/raw/img_01.jpg", # [1]  Reuben — Morning Cliffs
	"res://assets/sprites/raw/img_02.jpg", # [2]  Simeon — Desert Plains
	"res://assets/sprites/raw/img_03.jpg", # [3]  Levi   — Night Sanctuary
	"res://assets/sprites/raw/img_04.jpg", # [4]  Judah  — Sunlit Hills
	"res://assets/sprites/raw/img_05.jpg", # [5]  Dan    — Foggy Coast
	"res://assets/sprites/raw/img_06.jpg", # [6]  Naphtali — Night Forest
	"res://assets/sprites/raw/img_07.jpg", # [7]  Gad    — Mountain Pass
	"res://assets/sprites/raw/img_08.jpg", # [8]  Asher  — Coastal Shore
	"res://assets/sprites/raw/img_09.jpg", # [9]  Issachar — Starfield Plain
	"res://assets/sprites/raw/img_10.jpg", # [10] Zebulun — Harbour Dawn
	"res://assets/sprites/raw/img_11.jpg", # [11] Joseph  — Fertile Valley
	"res://assets/sprites/raw/img_12.jpg", # [12] Benjamin — Bronze Hills
	"res://assets/sprites/raw/img_13.jpg", # [13] Main Menu scene
	"res://assets/sprites/raw/img_14.jpg", # [14] Avatar Pick scene
	"res://assets/sprites/raw/img_15.jpg", # [15] Lobby scene
	"res://assets/sprites/raw/img_16.jpg", # [16] Verse Vault scene
	"res://assets/sprites/raw/img_17.jpg", # [17] Finale scene
	"res://assets/sprites/raw/img_18.jpg", # [18] Character: young adult female
	"res://assets/sprites/raw/img_19.jpg", # [19] Character: elder male
	"res://assets/sprites/raw/img_20.jpg", # [20] Character: teen male
	"res://assets/sprites/raw/img_21.jpg", # [21] Character: young adult male
	"res://assets/sprites/raw/img_22.jpg", # [22] Character: elder female
	"res://assets/sprites/raw/img_23.jpg", # [23] Tool: shepherd's staff / rod
	"res://assets/sprites/raw/img_24.jpg", # [24] Item: scales of justice (Issachar)
	"res://assets/sprites/raw/img_25.jpg", # [25] Item: harp strings (Judah / Asher)
	"res://assets/sprites/raw/img_26.jpg", # [26] Item: olive branch (Asher)
	"res://assets/sprites/raw/img_27.jpg", # [27] Item: carved stone tablet
	"res://assets/sprites/raw/img_28.jpg", # [28] Detail: cave entrance (Reuben)
	"res://assets/sprites/raw/img_29.jpg", # [29] Detail: forest canopy (Naphtali)
	"res://assets/sprites/raw/img_30.jpg", # [30] Detail: harbour boats (Zebulun)
	"res://assets/sprites/raw/img_31.jpg", # [31] Detail: star canopy (Issachar)
	"res://assets/sprites/raw/img_32.jpg", # [32] Special: ephod breastplate
	"res://assets/sprites/raw/img_33.jpg", # [33] Special: 12 gemstones array
	"res://assets/sprites/raw/img_34.jpg", # [34] Special: altar / holy fire
	"res://assets/sprites/raw/img_35.jpg", # [35] Special: assembly / courtyard
]

# ─────────────────────────────────────────────────────────────────────────────
# MUSIC TRACKS
# "Praise him with the harp and lyre, praise him with timbrel and dancing" – Ps 150:3
# ─────────────────────────────────────────────────────────────────────────────
const MUSIC: Dictionary = {
	# Per-tribe quest themes — each tribe's world plays its own track
	"reuben": "res://assets/audio/music/reuben_theme.wav",
	"simeon": "res://assets/audio/music/simeon_theme.wav",
	"levi": "res://assets/audio/music/incense_in_the_vaulted_air.wav",
	"judah": "res://assets/audio/music/lion_of_the_dawn.wav",
	"dan": "res://assets/audio/music/caves_and_hills.wav",
	"naphtali": "res://assets/audio/music/naphtali_theme.wav",
	"gad": "res://assets/audio/music/gather_the_tribes.wav",
	"asher": "res://assets/audio/music/sunrise_over_the_valley.wav",
	"issachar": "res://assets/audio/music/circle_of_bright_mornings.wav",
	"zebulun": "res://assets/audio/music/gathering_at_the_gates.wav",
	"joseph": "res://assets/audio/music/desert_sanctuary_main_theme.wav",
	"benjamin": "res://assets/audio/music/inspired_by_my_best.wav",

	# Scene themes
	"main_menu": "res://assets/audio/music/main_menu.ogg",
	"lobby": "res://assets/audio/music/gather_the_tribes_2.wav",
	"verse_vault": "res://assets/audio/music/sacred_spark.wav",
	"finale": "res://assets/audio/music/finale_main.wav",
	"finale_alt": "res://assets/audio/music/finale_alt1.wav",
	"finale_sting": "res://assets/audio/music/finale_sting.wav",
	"discovery": "res://assets/audio/music/soft_stone_discovery.wav",
	"success_tap": "res://assets/audio/music/soft_tap_of_yes.wav",
}

# ─────────────────────────────────────────────────────────────────────────────
# SFX (sound effects — all clean-named files)
# ─────────────────────────────────────────────────────────────────────────────
const SFX: Dictionary = {
	# Interaction
	"click": "res://assets/audio/sfx/click.wav",
	"tap": "res://assets/audio/sfx/tap.wav",
	"ui_open": "res://assets/audio/sfx/ui_open.wav",
	"ui_close": "res://assets/audio/sfx/ui_close.wav",
	"swipe": "res://assets/audio/sfx/swipe_whoosh.wav",

	# Player / world
	# footstep.wav is a 144-byte stub — use click.wav (real sound) as fallback
	"footstep": "res://assets/audio/sfx/click.wav",
	"chest_open": "res://assets/audio/sfx/chest_open.wav",
	"pickup": "res://assets/audio/sfx/stone_collect.wav",
	"stone_collect": "res://assets/audio/sfx/stone_collect.wav",
	"stone_drop": "res://assets/audio/sfx/stone_drop.wav",
	"stone_unlock": "res://assets/audio/sfx/stone_unlock.wav",

	# Mini-games
	"rhythm_beat": "res://assets/audio/sfx/rhythm_beat.wav",
	"rhythm_miss": "res://assets/audio/sfx/rhythm_miss.wav",
	"sort_snap": "res://assets/audio/sfx/sort_snap.wav",
	"sort_wrong": "res://assets/audio/sfx/sort_wrong.wav",
	"chain_link": "res://assets/audio/sfx/chain_link.wav",
	"chain_complete": "res://assets/audio/sfx/chain_complete.wav",
	"timeout": "res://assets/audio/sfx/timeout_gentle.wav",
	"success": "res://assets/audio/sfx/chime_cascade.wav",

	# Celebration / milestone
	"heart_badge": "res://assets/audio/sfx/heart_badge.wav",
	"chime": "res://assets/audio/sfx/chime_cascade.wav",
	"celebration": "res://assets/audio/sfx/celebration_clap.wav",
	"crowd_ahh": "res://assets/audio/sfx/crowd_ahh.wav",
	"ephod_complete": "res://assets/audio/sfx/ephod_complete.wav",
	"trumpet": "res://assets/audio/sfx/trumpet_shofar.wav",
	"bells": "res://assets/audio/sfx/bells_small.wav",
	"stars_shimmer": "res://assets/audio/sfx/stars_shimmer.wav",

	# Lobby
	"lobby_join": "res://assets/audio/sfx/lobby_join.wav",
	"lobby_ready": "res://assets/audio/sfx/lobby_ready.wav",

	# Nature ambience
	"butterfly": "res://assets/audio/sfx/butterfly.wav",
	"campfire": "res://assets/audio/sfx/campfire_crackle.wav",
	"deer": "res://assets/audio/sfx/deer_run.wav",
	"donkey": "res://assets/audio/sfx/donkey_clip.wav",
	"sheep": "res://assets/audio/sfx/sheep_bleat.wav",
	"roar": "res://assets/audio/sfx/roar_echo.wav",
	"sail_wind": "res://assets/audio/sfx/sail_wind.wav",
	"snake": "res://assets/audio/sfx/snake_rattle.wav",
	"olive_press": "res://assets/audio/sfx/olive_press.wav",
	"bread_break": "res://assets/audio/sfx/bread_break.wav",
}

# ─────────────────────────────────────────────────────────────────────────────
# PER-TRIBE SURFACE RECOMMENDATIONS
# WorldBase uses these to auto-pick the best terrain/wall for each tribe world
# ─────────────────────────────────────────────────────────────────────────────
const TRIBE_TERRAIN: Dictionary = {
	"reuben": "dirt_red", # red morning cliffs, iron-stained earth
	"simeon": "desert", # harsh desert plains
	"levi": "flagstone", # sacred hall pavement
	"judah": "sandstone", # sunlit hills, warm limestone
	"dan": "sand_wet", # foggy coast, damp sand
	"naphtali": "meadow", # night forest floor, dark moss
	"gad": "gravel", # mountain pass grit
	"asher": "grass", # coastal fertile fields
	"issachar": "loam", # Jezreel valley, rich farmland
	"zebulun": "sand", # harbour dunes
	"joseph": "grass_field", # fertile valley, abundant grain
	"benjamin": "dirt_clay", # bronze hill clay
}

const TRIBE_WALL: Dictionary = {
	"reuben": "cliff_red", # sandstone cliff faces
	"simeon": "cliff", # chalk desert cliffs
	"levi": "carved_panel", # carved cedar interior walls
	"judah": "limestone", # golden limestone walls
	"dan": "rock_dark", # dark coastal basalt
	"naphtali": "cave_wall", # dark forest stone
	"gad": "rock_rough", # mountain fortress walls
	"asher": "olive_wood", # olive tree groven walls
	"issachar": "ashlar", # dressed stone walls
	"zebulun": "rock", # harbour breakwater rock
	"joseph": "cedar", # white cedar beams (Egypt inspired)
	"benjamin": "bronze", # bronze-sheathed gates
}

const TRIBE_NPC_SKIN: Dictionary = {
	"reuben": "skin_olive",
	"simeon": "skin_dark",
	"levi": "skin_medium",
	"judah": "skin_tan",
	"dan": "skin_brown",
	"naphtali": "skin_light",
	"gad": "skin_deep",
	"asher": "skin_warm",
	"issachar": "skin_olive",
	"zebulun": "skin_medium",
	"joseph": "skin_tan",
	"benjamin": "skin_brown",
}

const TRIBE_NPC_ROBE: Dictionary = {
	"reuben": "robe_red",
	"simeon": "robe_purple",
	"levi": "robe_white",
	"judah": "robe_gold",
	"dan": "robe_blue",
	"naphtali": "robe_green",
	"gad": "tunic_grey",
	"asher": "robe_green",
	"issachar": "linen_robe",
	"zebulun": "robe_blue",
	"joseph": "tunic_brown",
	"benjamin": "robe_red",
}

# ─────────────────────────────────────────────────────────────────────────────
# PUBLIC API  (static helpers — call without an instance)
# ─────────────────────────────────────────────────────────────────────────────


## Returns a resolved "res://" texture path for a semantic terrain key,
## or the first TERRAIN entry if key is unknown.
static func terrain(key: String) -> String:
	var uuid: String = TERRAIN.get(key, TERRAIN.values()[0]) as String
	return _BASE + uuid


## Returns a resolved wall texture path.
static func wall(key: String) -> String:
	var uuid: String = WALL.get(key, WALL.values()[0]) as String
	return _BASE + uuid


## Returns a resolved prop texture path.
static func prop(key: String) -> String:
	var uuid: String = PROP.get(key, PROP.values()[0]) as String
	return _BASE + uuid


## Returns a resolved character texture path.
static func char_tex(key: String) -> String:
	var uuid: String = CHAR.get(key, CHAR.values()[0]) as String
	return _BASE + uuid


## Returns the artwork path for 1-based index (1–35).
static func artwork(index: int) -> String:
	if index < 1 or index >= ARTWORK.size():
		return ""
	return ARTWORK[index]


## Returns the best terrain path for a tribe key.
static func tribe_terrain(tribe: String) -> String:
	var k: String = TRIBE_TERRAIN.get(tribe, "stone") as String
	return terrain(k)


## Returns the best wall texture path for a tribe key.
static func tribe_wall(tribe: String) -> String:
	var k: String = TRIBE_WALL.get(tribe, "rock") as String
	return wall(k)


## Returns the NPC skin texture path for a tribe key.
static func tribe_skin(tribe: String) -> String:
	var k: String = TRIBE_NPC_SKIN.get(tribe, "skin_medium") as String
	return char_tex(k)


## Returns the NPC robe texture path for a tribe key.
static func tribe_robe(tribe: String) -> String:
	var k: String = TRIBE_NPC_ROBE.get(tribe, "robe_white") as String
	return char_tex(k)


## Returns the resolved music path for a tribe or scene key.
## Falls back to sacred_spark if missing.
static func music(key: String) -> String:
	var path: String = MUSIC.get(key, "") as String
	if path == "":
		return _MUS + "sacred_spark.wav"
	return path


## Returns a random terrain texture from the given category prefix.
## e.g. AssetRegistry.random_terrain("grass") picks any grass_* variant.
static func random_terrain(prefix: String) -> String:
	var matches: Array = []
	for k: String in TERRAIN.keys():
		if (k as String).begins_with(prefix):
			matches.append(_BASE + TERRAIN[k])
	if matches.is_empty():
		return terrain(prefix)
	matches.shuffle()
	return matches[0]


## Returns the SFX path for a semantic key or "" if not found.
static func sfx(key: String) -> String:
	return SFX.get(key, "") as String


## Returns the full path to a UI sprite by key (e.g. "panel_parchment").
## Returns "" if the key is unknown.
static func ui(key: String) -> String:
	return UI.get(key, "") as String


## Returns the full path to a video clip by key (e.g. "splash_intro").
## Note: MP4 playback requires the FFMpeg GDExtension on web export.
## Returns "" if the key is unknown.
static func video(key: String) -> String:
	return VIDEO.get(key, "") as String


## Returns the gem SVG path for a tribe key (e.g. "reuben").
## "A ruby, a topaz and a beryl…" — Exodus 28:17
static func gem(tribe: String) -> String:
	return GEMS.get(tribe, "") as String


## Returns the elder portrait SVG path for a tribe key.
## "Grey hair is a crown of splendour" — Proverbs 16:31
static func elder(tribe: String) -> String:
	return ELDERS.get(tribe, "") as String


## Returns the nature icon SVG path for a key (e.g. "butterfly", "eagle").
## "He speaks to them of trees" — 1 Kings 4:33
static func nature_icon(key: String) -> String:
	return NATURE.get(key, "") as String


## Returns an avatar SVG path by index [0..31].
## "I am fearfully and wonderfully made" — Psalm 139:14
static func avatar(index: int) -> String:
	if index < 0 or index >= AVATARS.size():
		return ""
	return AVATARS[index] as String


## Returns a random avatar SVG path.
static func random_avatar() -> String:
	return AVATARS[randi() % AVATARS.size()] as String


## Returns a background scene SVG path by key (e.g. "courtyard_pillars").
static func bg(key: String) -> String:
	return BACKGROUNDS.get(key, "") as String

# ─────────────────────────────────────────────────────────────────────────────
# CHARACTERS — diverse child/avatar sprites from reference art
# Key pattern: "girl_light_curly", "boy_olive_curly", "prayer_pair", etc.
# ─────────────────────────────────────────────────────────────────────────────
const CHARACTERS: Dictionary = {
	"girl_light_curly": "res://assets/sprites/characters/girl_light_curly.svg",
	"boy_light_dark": "res://assets/sprites/characters/boy_light_dark.svg",
	"boy_olive_curly": "res://assets/sprites/characters/boy_olive_curly.svg",
	"boy_olive_short": "res://assets/sprites/characters/boy_olive_short.svg",
	"boy_dark_tightcurl": "res://assets/sprites/characters/boy_dark_tightcurl.svg",
	"boy_deep_smooth": "res://assets/sprites/characters/boy_deep_smooth.svg",
	"girl_tan_straight": "res://assets/sprites/characters/girl_tan_straight.svg",
	"girl_olive_braid": "res://assets/sprites/characters/girl_olive_braid.svg",
	"boy_light_gold": "res://assets/sprites/characters/boy_light_gold.svg",
	"girl_dark_coils": "res://assets/sprites/characters/girl_dark_coils.svg",
	"boy_tan_bangs": "res://assets/sprites/characters/boy_tan_bangs.svg",
	"girl_light_auburn": "res://assets/sprites/characters/girl_light_auburn.svg",
	"boy_medium_waves": "res://assets/sprites/characters/boy_medium_waves.svg",
	"boy_copper_locs": "res://assets/sprites/characters/boy_copper_locs.svg",
	"prayer_pair": "res://assets/sprites/characters/prayer_pair.svg",
}


## Returns a character SVG path by key (e.g. "girl_light_curly").
static func character(key: String) -> String:
	return CHARACTERS.get(key, "") as String

# ─────────────────────────────────────────────────────────────────────────────
# TOOLS — biblical implements (labeled as tools; available for future quests)
# ─────────────────────────────────────────────────────────────────────────────
const TOOLS: Dictionary = {
	"shepherd_staff": "res://assets/sprites/tools/shepherd_staff.svg",
	"oil_lamp": "res://assets/sprites/tools/oil_lamp.svg",
	"olive_branch": "res://assets/sprites/tools/olive_branch.svg",
	"clay_jug": "res://assets/sprites/tools/clay_jug.svg",
	"cedar_plank": "res://assets/sprites/tools/cedar_plank.svg",
	"scroll_sealed": "res://assets/sprites/tools/scroll_sealed.svg",
	"stone_chisel": "res://assets/sprites/tools/stone_chisel.svg",
	"fishing_net": "res://assets/sprites/tools/fishing_net.svg",
	"bread_loaf": "res://assets/sprites/tools/bread_loaf.svg",
	"balance_scales": "res://assets/sprites/tools/balance_scales.svg",
}


## Returns a tool SVG path by key (e.g. "shepherd_staff").
static func tool(key: String) -> String:
	return TOOLS.get(key, "") as String

# ─────────────────────────────────────────────────────────────────────────────
# ITEMS — game collectibles / quest items (Exodus 28 ephod variants)
# ─────────────────────────────────────────────────────────────────────────────
const ITEMS: Dictionary = {
	"ephod_flat": "res://assets/sprites/items/ephod_flat.svg",
	"ephod_held": "res://assets/sprites/items/ephod_held.svg",
}


## Returns an item SVG path by key (e.g. "ephod_held").
static func item(key: String) -> String:
	return ITEMS.get(key, "") as String

# ─────────────────────────────────────────────────────────────────────────────
# ELDER VARIANTS — additional reference-art elder styles (beyond the 12 tribe elders)
# Use elder(tribe) for tribe-specific; use elder_variant(key) for scene-generic
# ─────────────────────────────────────────────────────────────────────────────
const ELDER_VARIANTS: Dictionary = {
	"elder_grey_teal": "res://assets/sprites/elders/elder_grey_teal.svg",
	"elder_white_tan": "res://assets/sprites/elders/elder_white_tan.svg",
	"elder_white_grey": "res://assets/sprites/elders/elder_white_grey.svg",
	"elder_dark_olive": "res://assets/sprites/elders/elder_dark_olive.svg",
	"elder_white_brown": "res://assets/sprites/elders/elder_white_brown.svg",
	"elder_silver_blue": "res://assets/sprites/elders/elder_silver_blue.svg",
}


## Returns a generic (non-tribe) elder variant SVG path by key.
static func elder_variant(key: String) -> String:
	return ELDER_VARIANTS.get(key, "") as String

# ─────────────────────────────────────────────────────────────────────────────
# NATURE EXTENDED — additional nature/animal sprites from reference art
# (complements the NATURE dict already defined above)
# ─────────────────────────────────────────────────────────────────────────────
const NATURE_EXT: Dictionary = {
	"butterfly_colorful": "res://assets/sprites/nature/butterfly_colorful.svg",
	"butterfly_pastel": "res://assets/sprites/nature/butterfly_pastel.svg",
	"eagle_soaring": "res://assets/sprites/nature/eagle_soaring.svg",
	"eagle_profile": "res://assets/sprites/nature/eagle_profile.svg",
	"cat_companion": "res://assets/sprites/nature/cat_companion.svg",
}


## Returns an extended nature SVG path. Checks NATURE_EXT then falls back to NATURE.
static func nature_ext(key: String) -> String:
	if NATURE_EXT.has(key):
		return NATURE_EXT[key] as String
	return nature_icon(key)

# ─────────────────────────────────────────────────────────────────────────────
# REFERENCE ART — organized catalogue of all 57 production reference images.
# These drove every colour, character, and lighting decision in WorldGenerator.
# Use for in-editor previews, art direction, and future sprite extraction.
# "From him the whole body…grows as God causes it to grow." – Col 2:19
# ─────────────────────────────────────────────────────────────────────────────
const REFERENCE_ART_CHARS: Array[String] = [
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
]

const REFERENCE_ART_GROUPS: Array[String] = [
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
]

const REFERENCE_ART_SCENES: Array[String] = [
	"res://assets/reference_art/scenes/scene_001.jpg",
	"res://assets/reference_art/scenes/scene_002.jpg",
]

const REFERENCE_ART_ORIGINALS: Array[String] = [
	"res://assets/reference_art/batch_originals/original_c0112e1e.jpg",
	"res://assets/reference_art/batch_originals/original_3ec225d0.jpg",
	"res://assets/reference_art/batch_originals/original_2adf0f7f.jpg",
	"res://assets/reference_art/batch_originals/original_19c97e69.jpg",
]


## Returns a reference character image path by 1-based index (1–40).
static func reference_char(n: int) -> String:
	var idx: int = clamp(n - 1, 0, REFERENCE_ART_CHARS.size() - 1)
	return REFERENCE_ART_CHARS[idx]


## Returns a reference group image path by 1-based index (1–11).
static func reference_group(n: int) -> String:
	var idx: int = clamp(n - 1, 0, REFERENCE_ART_GROUPS.size() - 1)
	return REFERENCE_ART_GROUPS[idx]


## Returns a reference scene image path by 1-based index (1–2).
static func reference_scene(n: int) -> String:
	var idx: int = clamp(n - 1, 0, REFERENCE_ART_SCENES.size() - 1)
	return REFERENCE_ART_SCENES[idx]
