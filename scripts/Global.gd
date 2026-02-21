extends Node
# ─────────────────────────────────────────────────────────────────────────────
# Global.gd  –  Twelve Stones / Ephod Quest
# Central game-state autoload.  All scenes read / write through here.
# "The LORD is my shepherd" – Psalm 23:1
# ─────────────────────────────────────────────────────────────────────────────

signal stones_changed
signal verse_memorized(tribe: String)
signal save_completed

# ── Save-file location ────────────────────────────────────────────────────────
const SAVE_PATH := "user://twelve_stones_save.json"

# ── Current session ───────────────────────────────────────────────────────────
var selected_tribe:  String = ""
var selected_avatar: String = ""   # avatar key e.g. "reuben_naomi"
var player_name:     String = "Child"

# ── Progress ──────────────────────────────────────────────────────────────────
var stones:            Array[String] = []          # tribes whose stone is collected
var memorized_verses:  Array[String] = []          # verse keys memorized
var completed_quests:  Array[String] = []          # "reuben_main", "judah_side1" …
var journal_entries:   Dictionary   = {}           # tribe → Array[String notes]
var heart_badges:      Array[String] = []          # verse keys with badge glow
var treasures_found:   Array[String] = []          # chest IDs opened across all worlds
var world_positions:   Dictionary   = {}           # tribe → Vector2 last player pos

# Derived from stones — tribes that have completed their main quest.
# Used by Finale.gd to populate the tribe circle.
var completed_tribes: Array[String]:
	get:
		return stones.duplicate()

# ─────────────────────────────────────────────────────────────────────────────
# TRIBE DATA
# Each tribe has: elder_name, trait, color (hex), gem, stone_name,
#                 quest_verse (reference + text), nature_fact, nature_verse
# "The tribes of the LORD" – Psalm 122:4
# ─────────────────────────────────────────────────────────────────────────────
const TRIBES: Dictionary = {
	"reuben": {
		"display": "Reuben",
		"elder": "Elder Hanoch",
		"trait": "First-born courage — learning when to pause",
		"color": "#C0392B",           # ruby red
		"gem": "ruby",
		"stone_name": "Sardius",
		"quest_verse_ref": "Proverbs 3:5-6",
		"quest_verse": "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.",
		"nature_fact": "Butterflies taste with their feet — they land gently before they know if something is sweet.",
		"nature_verse_ref": "2 Corinthians 5:17",
		"nature_verse": "Therefore, if anyone is in Christ, the new creation has come: the old has gone, the new is here!"
	},
	"simeon": {
		"display": "Simeon",
		"elder": "Elder Nemuel",
		"trait": "Listening and turning — hearing God's voice in stillness",
		"color": "#8E44AD",
		"gem": "topaz",
		"stone_name": "Topaz",
		"quest_verse_ref": "Psalm 46:10",
		"quest_verse": "Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth.",
		"nature_fact": "Sheep recognise their shepherd's individual voice and will not follow a stranger — even among hundreds of sheep.",
		"nature_verse_ref": "John 10:27",
		"nature_verse": "My sheep listen to my voice; I know them, and they follow me."
	},
	"levi": {
		"display": "Levi",
		"elder": "Elder Gershon",
		"trait": "Dedicated service — keeping the sacred lamp burning",
		"color": "#D4AC0D",
		"gem": "emerald",
		"stone_name": "Carbuncle",
		"quest_verse_ref": "Matthew 5:16",
		"quest_verse": "In the same way, let your light shine before others, that they may see your good deeds and glorify your Father in heaven.",
		"nature_fact": "Fireflies produce cold light — nearly 100% of their energy becomes light, none wasted as heat.",
		"nature_verse_ref": "Daniel 12:3",
		"nature_verse": "Those who are wise will shine like the brightness of the heavens, and those who lead many to righteousness, like the stars for ever and ever."
	},
	"judah": {
		"display": "Judah",
		"elder": "Elder Shelah",
		"trait": "Bold praise — the roar that opens the way",
		"color": "#F39C12",           # gold
		"gem": "emerald",
		"stone_name": "Emerald",
		"quest_verse_ref": "Psalm 100:1-2",
		"quest_verse": "Shout for joy to the LORD, all the earth. Worship the LORD with gladness; come before him with joyful songs.",
		"nature_fact": "Male lions' roars can be heard up to 8 km away — the sound travels at dawn to mark safe territory for the pride.",
		"nature_verse_ref": "Revelation 5:5",
		"nature_verse": "See, the Lion of the tribe of Judah, the Root of David, has triumphed."
	},
	"dan": {
		"display": "Dan",
		"elder": "Elder Shuham",
		"trait": "Sharp discernment — seeing what is hidden",
		"color": "#1ABC9C",
		"gem": "sapphire",
		"stone_name": "Sapphire",
		"quest_verse_ref": "Proverbs 2:6",
		"quest_verse": "For the LORD gives wisdom; from his mouth come knowledge and understanding.",
		"nature_fact": "Eagles have five-times-sharper vision than humans and can spot a rabbit from nearly 3 km away.",
		"nature_verse_ref": "Isaiah 40:31",
		"nature_verse": "But those who hope in the LORD will renew their strength. They will soar on wings like eagles."
	},
	"naphtali": {
		"display": "Naphtali",
		"elder": "Elder Jahzeel",
		"trait": "Graceful swiftness — carrying good news with joy",
		"color": "#27AE60",           # sapphire-teal
		"gem": "diamond",
		"stone_name": "Diamond",
		"quest_verse_ref": "Isaiah 52:7",
		"quest_verse": "How beautiful on the mountains are the feet of those who bring good news, who proclaim peace.",
		"nature_fact": "Hummingbirds beat their wings up to 80 times per second and can fly backwards — true agility in God's creation.",
		"nature_verse_ref": "Psalm 147:15",
		"nature_verse": "He sends his command to the earth; his word runs swiftly."
	},
	"gad": {
		"display": "Gad",
		"elder": "Elder Zephon",
		"trait": "Steadfast endurance — holding the line for others",
		"color": "#566573",
		"gem": "ligure",
		"stone_name": "Ligure",
		"quest_verse_ref": "Hebrews 12:1",
		"quest_verse": "Let us run with perseverance the race marked out for us, fixing our eyes on Jesus.",
		"nature_fact": "Olive trees can live over 2 000 years — some in the Garden of Gethsemane may have shaded the very path Jesus walked.",
		"nature_verse_ref": "Psalm 52:8",
		"nature_verse": "But I am like an olive tree flourishing in the house of God; I trust in God's unfailing love for ever and ever."
	},
	"asher": {
		"display": "Asher",
		"elder": "Elder Imnah",
		"trait": "Generous provision — bread shared doubles the blessing",
		"color": "#F7DC6F",
		"gem": "agate",
		"stone_name": "Agate",
		"quest_verse_ref": "Luke 9:16",
		"quest_verse": "Taking the five loaves and the two fish and looking up to heaven, he gave thanks and broke them.",
		"nature_fact": "Honeybees communicate the exact location of flowers by performing a 'waggle dance' — direction, distance, and quality all encoded in their movement.",
		"nature_verse_ref": "Proverbs 16:24",
		"nature_verse": "Gracious words are a honeycomb, sweet to the soul and healing to the bones."
	},
	"issachar": {
		"display": "Issachar",
		"elder": "Elder Tola",
		"trait": "Patient wisdom — knowing the seasons and times",
		"color": "#A569BD",
		"gem": "amethyst",
		"stone_name": "Amethyst",
		"quest_verse_ref": "1 Chronicles 12:32",
		"quest_verse": "From Issachar, men who understood the times and knew what Israel should do.",
		"nature_fact": "Monarch butterflies migrate up to 4 500 km and return to the exact same grove their great-grandparents used — guided by the sun and Earth's magnetic field.",
		"nature_verse_ref": "Ecclesiastes 3:1",
		"nature_verse": "There is a time for everything, and a season for every activity under the heavens."
	},
	"zebulun": {
		"display": "Zebulun",
		"elder": "Elder Sered",
		"trait": "Welcoming hospitality — open shores, open doors",
		"color": "#2E86C1",
		"gem": "beryl",
		"stone_name": "Beryl",
		"quest_verse_ref": "Romans 15:7",
		"quest_verse": "Accept one another, then, just as Christ accepted you, in order to bring praise to God.",
		"nature_fact": "Clownfish live inside sea anemones — the fish keeps it clean while the anemone protects the fish. Creation designed in mutual care.",
		"nature_verse_ref": "Ecclesiastes 4:9",
		"nature_verse": "Two are better than one, because they have a good return for their labor."
	},
	"joseph": {
		"display": "Joseph",
		"elder": "Elder Ephraim",
		"trait": "Forgiveness and fruitfulness — God turns hurt into harvest",
		"color": "#E74C3C",
		"gem": "onyx",
		"stone_name": "Onyx",
		"quest_verse_ref": "Genesis 50:20",
		"quest_verse": "You intended to harm me, but God intended it for good to accomplish what is now being done.",
		"nature_fact": "Pearls form when an oyster coats an irritant — layer by layer — into something of great beauty and value.",
		"nature_verse_ref": "Romans 8:28",
		"nature_verse": "And we know that in all things God works for the good of those who love him."
	},
	"benjamin": {
		"display": "Benjamin",
		"elder": "Elder Bela",
		"trait": "Beloved youngest — fierceness held inside gentleness",
		"color": "#E67E22",
		"gem": "jasper",
		"stone_name": "Jasper",
		"quest_verse_ref": "Deuteronomy 33:12",
		"quest_verse": "Let the beloved of the LORD rest secure in him, for he shields him all day long, and the one the LORD loves rests between his shoulders.",
		"nature_fact": "Wolf pups are cared for by the whole pack — every adult helps raise and protect them. None are left alone.",
		"nature_verse_ref": "Zephaniah 3:17",
		"nature_verse": "The LORD your God is with you, the Mighty Warrior who saves. He will take great delight in you."
	}
}

# ─────────────────────────────────────────────────────────────────────────────
# AVATAR DATA  –  Ages 12-29, diverse skin / hair / eye / body
# Each avatar has a 2-line backstory and a small gameplay_edge hint
# "I praise you because I am fearfully and wonderfully made" – Psalm 139:14
# ─────────────────────────────────────────────────────────────────────────────
const AVATARS: Dictionary = {
	"reuben": [
		{"key": "naomi",   "name": "Naomi",   "age": 14, "skin": "warm brown",  "hair": "black coils", "eyes": "hazel",  "build": "sturdy",   "backstory": "Naomi's family tends goats on the ridge above the Jordan. She climbs every day and knows every handhold.", "gameplay_edge": "Climbs ladder 15% faster"},
		{"key": "caleb_r", "name": "Caleb",   "age": 17, "skin": "olive",       "hair": "dark wavy",   "eyes": "brown",  "build": "lean",     "backstory": "Caleb loves sunrise — he's always exploring before anyone else wakes, mapping the caves near his village.", "gameplay_edge": "Reveals hidden paths on map"},
		{"key": "miriam_r","name": "Miriam",  "age": 12, "skin": "light tan",   "hair": "auburn plaits","eyes": "green", "build": "slight",   "backstory": "Miriam is the youngest but memorises verses fastest — her grandmother taught her to see words as pictures.", "gameplay_edge": "Verse memorisation timer +20%"},
		{"key": "ezra_r",  "name": "Ezra",    "age": 20, "skin": "deep mahogany","hair": "close crop", "eyes": "dark brown","build": "broad", "backstory": "Ezra grew up near a butterfly meadow. He knows which flowers attract them and why they dance in spirals.", "gameplay_edge": "Butterfly mini-game clue visible"}
	],
	"simeon": [
		{"key": "tamar_s", "name": "Tamar",   "age": 15, "skin": "golden tan",  "hair": "long dark",   "eyes": "amber",  "build": "average",  "backstory": "Tamar tends the flock at dusk and has learnt that sheep know her hum — she uses it to calm them.", "gameplay_edge": "Sheep-call mini-game easier"},
		{"key": "samuel_s","name": "Samuel",  "age": 18, "skin": "warm olive",  "hair": "short curly", "eyes": "hazel",  "build": "lean",     "backstory": "Samuel lost his voice for a week once and had to listen to understand — now he hears things others miss.", "gameplay_edge": "Hidden dialogue unlocked"},
		{"key": "leah_s",  "name": "Leah",    "age": 13, "skin": "fair freckled","hair": "copper braid","eyes": "blue",  "build": "slight",   "backstory": "Leah draws maps of where she hears God's whisper — in reed beds, on the threshing floor, under stars.", "gameplay_edge": "Map shows quiet zones"},
		{"key": "tobias_s","name": "Tobias",  "age": 22, "skin": "rich brown",  "hair": "locs",        "eyes": "brown",  "build": "stocky",   "backstory": "Tobias is training to be a shepherd elder. He practices stillness every morning before the camp stirs.", "gameplay_edge": "Stillness challenge bonus"}
	],
	"levi": [
		{"key": "anna_l",  "name": "Anna",    "age": 16, "skin": "light olive",  "hair": "dark updo",  "eyes": "brown",  "build": "slender",  "backstory": "Anna loves tending the lampstand most — she says each flame reminds her of a person God is watching over.", "gameplay_edge": "Lamp-lighting mini-game speed boost"},
		{"key": "micah_l", "name": "Micah",   "age": 19, "skin": "medium brown", "hair": "black waves", "eyes": "dark",   "build": "average",  "backstory": "Micah copies scrolls at night. His neat letters once helped decipher a torn parchment no one else could read.", "gameplay_edge": "Scroll-reading puzzle easier"},
		{"key": "ruth_l",  "name": "Ruth",    "age": 14, "skin": "warm tan",     "hair": "braided bun", "eyes": "green",  "build": "slight",   "backstory": "Ruth's father is a Levitical singer. She has memorised every psalm by melody rather than by word order.", "gameplay_edge": "Musical verse challenge immune to timer"},
		{"key": "amos_l",  "name": "Amos",    "age": 25, "skin": "deep brown",   "hair": "shaved close","eyes": "amber",  "build": "broad",    "backstory": "Amos was born with one arm shorter than the other. He fashioned a special crook to tend lamps anyway.", "gameplay_edge": "One-hand tap puzzle accessible mode"}
	],
	"judah": [
		{"key": "david_j", "name": "David",   "age": 17, "skin": "warm brown",   "hair": "dark curls",  "eyes": "hazel",  "build": "athletic", "backstory": "David is named after the great king. He fears living up to the name, but his praise voice is unmistakable.", "gameplay_edge": "Praise-roar mini fills faster"},
		{"key": "esther_j","name": "Esther",  "age": 21, "skin": "olive",        "hair": "long black",  "eyes": "brown",  "build": "average",  "backstory": "Esther memorized 40 royal greetings to help her family trade in the market. Her voice is steady under pressure.", "gameplay_edge": "Rhythm perfect-window wider"},
		{"key": "joel_j",  "name": "Joel",    "age": 13, "skin": "pale tan",     "hair": "blond waves",  "eyes": "blue",  "build": "slight",   "backstory": "Joel is the youngest in his household but loves to lead dawn songs. Even his grandmother follows his pitch.", "gameplay_edge": "Group praise bubble travels further"},
		{"key": "abigail_j","name":"Abigail", "age": 28, "skin": "copper-brown", "hair": "thick coils", "eyes": "dark brown","build":"sturdy","backstory": "Abigail is a mentor figure who lost her hearing partially — she learnt to praise by feeling the vibration.", "gameplay_edge": "Visual rhythm cue always shown"}
	],
	"dan": [
		{"key": "deborah_d","name":"Deborah", "age": 24, "skin": "warm olive",   "hair": "dark braids", "eyes": "amber",  "build": "lean",     "backstory": "Deborah trains younger children to look for patterns — patterns in rock strata, bird flight, and scripture.", "gameplay_edge": "Pattern lock solved in fewer taps"},
		{"key": "noah_d",  "name": "Noah",    "age": 16, "skin": "golden brown", "hair": "short black", "eyes": "hazel",  "build": "average",  "backstory": "Noah watches the eagles every morning to learn patience. He says an eagle's stillness is its secret weapon.", "gameplay_edge": "Eagle soar mini-game glide time +10%"},
		{"key": "hana_d",  "name": "Hana",    "age": 12, "skin": "fair",         "hair": "silver-white","eyes": "grey",   "build": "slight",   "backstory": "Hana was born with albinism. She sees people stare and has learnt to see what they are really feeling instead.", "gameplay_edge": "Hidden emotion cue visible in dialogue"},
		{"key": "cyrus_d", "name": "Cyrus",   "age": 19, "skin": "deep mahogany","hair": "tight coils", "eyes": "brown",  "build": "tall lean","backstory": "Cyrus charts the stars from his rooftop. He matched constellations to Psalm 19 last harvest season.", "gameplay_edge": "Night navigation map bonus"}
	],
	"naphtali": [
		{"key": "lyra_n",  "name": "Lyra",    "age": 15, "skin": "light tan",    "hair": "auburn loose","eyes": "green",  "build": "slim",     "backstory": "Lyra runs every morning before dawn, carrying messages between villages — joy is her fuel.", "gameplay_edge": "Sprint stamina higher"},
		{"key": "jared_n", "name": "Jared",   "age": 18, "skin": "medium brown", "hair": "dark twists", "eyes": "brown",  "build": "average",  "backstory": "Jared trained carrier doves and learnt that good news must be brief, gentle, and true.", "gameplay_edge": "Dialogue choices revealed faster"},
		{"key": "priya_n", "name": "Priya",   "age": 22, "skin": "warm brown",   "hair": "long black",  "eyes": "dark",   "build": "graceful", "backstory": "Priya's family is from a distant land. She translates languages and brought a verse from each culture she visited.", "gameplay_edge": "Extra verse unlock per quest"},
		{"key": "eli_n",   "name": "Eli",     "age": 14, "skin": "olive",        "hair": "short waves", "eyes": "hazel",  "build": "slight",   "backstory": "Eli uses a wheelchair and has mastered sending fast written scrolls via a pulley system he built himself.", "gameplay_edge": "Pulley puzzle solved instantly"}
	],
	"gad": [
		{"key": "zara_g",  "name": "Zara",    "age": 20, "skin": "rich brown",   "hair": "shoulder locs","eyes":"amber", "build": "strong",   "backstory": "Zara trains every day to be ready if her village needs protecting. She says endurance is a form of love.", "gameplay_edge": "Timer challenge +5 seconds"},
		{"key": "peter_g", "name": "Peter",   "age": 16, "skin": "pale freckled","hair": "red curls",   "eyes": "blue",   "build": "stocky",   "backstory": "Peter is clumsy but refuses to give up — he has fallen off every rope course in camp and climbed back every time.", "gameplay_edge": "Re-try penalty reduced"},
		{"key": "sela_g",  "name": "Sela",    "age": 14, "skin": "warm tan",     "hair": "black plaits","eyes": "brown",  "build": "slight",   "backstory": "Sela's grandmother pressed olives for sixty years. Sela learnt that patience and pressure together create something precious.", "gameplay_edge": "Olive-press mini bonus multiplier"},
		{"key": "asaph_g", "name": "Asaph",   "age": 27, "skin": "deep olive",   "hair": "greying waves","eyes":"green",  "build": "lean",     "backstory": "Asaph wrote songs during a difficult year. He says hard seasons are where the deepest praise is forged.", "gameplay_edge": "Endurance verse badge glow permanent"}
	],
	"asher": [
		{"key": "joy_a",   "name": "Joy",     "age": 13, "skin": "warm brown",   "hair": "puffs",       "eyes": "brown",  "build": "average",  "backstory": "Joy loves baking bread with her grandmother and always saves the crust for strangers who pass through.", "gameplay_edge": "Bread-sharing heals two players instead of one"},
		{"key": "marco_a", "name": "Marco",   "age": 17, "skin": "olive",        "hair": "dark short",  "eyes": "brown",  "build": "average",  "backstory": "Marco carries an extra water flask for anyone who forgets theirs — it's just what he does.", "gameplay_edge": "Healing radius wider"},
		{"key": "naomi_a", "name": "Naomi",   "age": 23, "skin": "golden tan",   "hair": "honey waves", "eyes": "hazel",  "build": "lean",     "backstory": "Naomi manages the camp kitchen. She once fed forty people with what looked like food for ten.", "gameplay_edge": "Provision mini-game portions doubled"},
		{"key": "tomas_a", "name": "Tomas",   "age": 15, "skin": "deep brown",   "hair": "tight afro",  "eyes": "dark",   "build": "sturdy",   "backstory": "Tomas has coeliac disease and understands what it means to need different bread. He never judges hunger.", "gameplay_edge": "Allergy-safe food item bonus unlock"}
	],
	"issachar": [
		{"key": "iris_i",  "name": "Iris",    "age": 29, "skin": "light brown",  "hair": "silver-streaked","eyes":"blue","build": "slight",   "backstory": "Iris is the tribe's calendar keeper. She reads seasons in the bark of trees and the flight of geese.", "gameplay_edge": "Season mini-game all clues shown"},
		{"key": "barak_i", "name": "Barak",   "age": 18, "skin": "warm brown",   "hair": "black cornrows","eyes":"hazel","build": "average",  "backstory": "Barak studies the patterns of harvest and famine. He says God's timing is always better noticed in hindsight.", "gameplay_edge": "Historical timeline puzzle auto-hint"},
		{"key": "lydia_i", "name": "Lydia",   "age": 14, "skin": "fair",         "hair": "ash blonde",   "eyes": "grey",   "build": "thin",     "backstory": "Lydia has a chronic illness and has learnt to pace herself — she says slow and wise beats fast and foolish.", "gameplay_edge": "Slow-walk path always optimal"},
		{"key": "kofi_i",  "name": "Kofi",    "age": 21, "skin": "deep brown",   "hair": "flat top",     "eyes": "dark",   "build": "broad",    "backstory": "Kofi arrived from a nation with a different calendar system and loves comparing them. Seasons feel sacred to him.", "gameplay_edge": "Bonus scroll unlocked for second-culture cross-reference"}
	],
	"zebulun": [
		{"key": "marina_z","name": "Marina",  "age": 16, "skin": "warm olive",   "hair": "curly brown", "eyes": "sea green","build":"lean",   "backstory": "Marina grew up beside the Sea of Galilee. She welcomes every newcomer with the same warmth the water shows the shore.", "gameplay_edge": "New-player greeting bonus"},
		{"key": "amos_z",  "name": "Amos",    "age": 24, "skin": "deep brown",   "hair": "short natural","eyes":"brown",  "build": "sturdy",   "backstory": "Amos is a harbour worker who has greeted traders from twelve nations. He says hospitality is a form of worship.", "gameplay_edge": "Trade negotiation mini faster resolve"},
		{"key": "grace_z", "name": "Grace",   "age": 12, "skin": "pale tan",     "hair": "dark plaits",  "eyes": "hazel",  "build": "slight",   "backstory": "Grace collects unusual pebbles from every beach she visits. Each one she sees as a reminder of God's creativity.", "gameplay_edge": "Hidden gem item visible on map"},
		{"key": "lior_z",  "name": "Lior",    "age": 19, "skin": "golden brown", "hair": "close crop",  "eyes": "amber",  "build": "average",  "backstory": "Lior is deaf and uses sign language that blends two regional dialects. His 'welcome' gesture became the camp standard.", "gameplay_edge": "Visual welcome animation shortcut"}
	],
	"joseph": [
		{"key": "joseph_w","name": "Joseph",  "age": 17, "skin": "warm brown",   "hair": "dark waves",  "eyes": "brown",  "build": "lean",     "backstory": "Joseph was teased for his colourful cloak but kept wearing it — he says what God gives you is worth being seen.", "gameplay_edge": "Forgiveness puzzle starts at 50%"},
		{"key": "sara_j",  "name": "Sara",    "age": 20, "skin": "olive",        "hair": "dark long",   "eyes": "hazel",  "build": "average",  "backstory": "Sara grew up in two different homes and understands what it means to find family where God places you.", "gameplay_edge": "Cross-tribe cooperation bonus doubled"},
		{"key": "remy_j",  "name": "Remy",    "age": 14, "skin": "light freckled","hair":"strawberry plaits","eyes":"green","build":"slight", "backstory": "Remy kept a journal through the hardest year of his life. He says God was in every painful page.", "gameplay_edge": "Journal entry unlocks hidden verse"},
		{"key": "adanna_j","name": "Adanna",  "age": 26, "skin": "deep mahogany","hair": "crown braids","eyes": "dark",   "build": "strong",   "backstory": "Adanna is a midwife's assistant. She has seen life begin in the hardest circumstances and always sees hope first.", "gameplay_edge": "Healing stone stone collected at half taps"}
	],
	"benjamin": [
		{"key": "ben_b",   "name": "Ben",     "age": 12, "skin": "warm tan",     "hair": "dark curls",  "eyes": "brown",  "build": "slight",   "backstory": "Ben is the youngest in camp and sometimes feels overlooked — but everyone notices when he isn't there.", "gameplay_edge": "Youngest bonus — other players receive +1 courage when Ben is in lobby"},
		{"key": "esther_b","name": "Esther",  "age": 18, "skin": "golden brown", "hair": "long braids", "eyes": "amber",  "build": "lean",     "backstory": "Esther stood up for a smaller child once at great personal cost. She runs toward the right thing, not away from the hard one.", "gameplay_edge": "Courage meter fills on behalf of others"},
		{"key": "paz_b",   "name": "Paz",     "age": 15, "skin": "olive",        "hair": "messy waves", "eyes": "green",  "build": "average",  "backstory": "Paz uses humour to make hard things approachable — every elder smiles when Paz asks a question.", "gameplay_edge": "Elder dialogue options + 1 gentle humour choice"},
		{"key": "nia_b",   "name": "Nia",     "age": 23, "skin": "deep brown",   "hair": "natural halo","eyes": "dark",   "build": "sturdy",   "backstory": "Nia is a wolf researcher who documents how pack love protects every member — especially the smallest.", "gameplay_edge": "Wolf mini-game vision wider"}
	]
}

# ─────────────────────────────────────────────────────────────────────────────
# CROSS-TRIBE CO-OP ACTIONS  –  "A cord of three strands is not quickly broken" – Eccl 4:12
# Triggered when two different tribes are both present in the lobby
# ─────────────────────────────────────────────────────────────────────────────
const COOP_ACTIONS: Dictionary = {
	"judah+reuben":   {"label": "Judah Roars — Reuben Climbs", "desc": "Judah's praise-voice shakes the cliff face loose. Reuben finds the next handhold."},
	"levi+gad":       {"label": "Levi Reads — Gad's Path Opens", "desc": "Levi recites the scroll aloud; the ancient inscription on the door glows and slides open for Gad."},
	"asher+all":      {"label": "Asher Shares Bread", "desc": "Asher breaks bread and passes it around. Every player in the group is refreshed and encouraged."},
	"naphtali+simeon":{"label": "Naphtali Carries Word — Simeon Stills the Flock", "desc": "Naphtali runs the message; Simeon's quiet song keeps the flock from scattering."},
	"dan+issachar":   {"label": "Dan Sees It — Issachar Knows the Moment", "desc": "Dan spots the hidden pattern; Issachar reads the season and confirms the right time to act."},
	"benjamin+joseph":{"label": "Benjamin Trusts — Joseph Forgives", "desc": "Benjamin steps forward in faith; Joseph's forgiveness removes the barrier between them."}
}

# ─────────────────────────────────────────────────────────────────────────────
# RUNTIME STATE
# ─────────────────────────────────────────────────────────────────────────────
var _swipe_start: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Psalm 23:1 — Let the Shepherd guide this session
	multiplayer.peer_connected.connect(_on_peer_connected)
	load_game()

func _input(event: InputEvent) -> void:
	# Enhanced touch-swipe detection → inject directional input events
	if event is InputEventScreenDrag:
		var delta: Vector2 = event.relative
		var threshold: float = 15.0  # More sensitive threshold
		
		# Clear previous actions first
		Input.action_release("move_left")
		Input.action_release("move_right")
		Input.action_release("move_up")
		Input.action_release("move_down")
		
		# Determine primary direction
		if abs(delta.x) > abs(delta.y):
			if delta.x < -threshold:
				Input.action_press("move_left")
			elif delta.x > threshold:
				Input.action_press("move_right")
		else:
			if delta.y < -threshold:
				Input.action_press("move_up")
			elif delta.y > threshold:
				Input.action_press("move_down")
	
	# Touch tap detection for interaction
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			# Store touch start for potential tap
			_touch_start_pos = touch.position
			_touch_start_time = Time.get_ticks_msec()
		else:
			# Check for tap (quick touch release)
			var touch_duration = Time.get_ticks_msec() - _touch_start_time
			var touch_distance = touch.position.distance_to(_touch_start_pos)
			
			if touch_duration < 300 and touch_distance < 20:  # 300ms, 20px threshold
				Input.action_press("ui_accept")
				# Release after a frame to simulate button press
				await get_tree().process_frame
				Input.action_release("ui_accept")

# Touch tracking variables
var _touch_start_pos: Vector2 = Vector2.ZERO
var _touch_start_time: int = 0

# ─────────────────────────────────────────────────────────────────────────────
# PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────
func add_stone(tribe: String) -> void:
	# "Twelve stones… one for each of the tribes" – Joshua 4:20
	if tribe not in stones:
		stones.append(tribe)
		stones_changed.emit()
		save_game()

func add_verse(tribe: String, verse_ref: String) -> void:
	if verse_ref not in memorized_verses:
		memorized_verses.append(verse_ref)
		verse_memorized.emit(tribe)
		save_game()

func add_journal_entry(tribe: String, text: String) -> void:
	if tribe not in journal_entries:
		journal_entries[tribe] = []
	journal_entries[tribe].append(text)
	save_game()

func complete_quest(quest_id: String) -> void:
	if quest_id not in completed_quests:
		completed_quests.append(quest_id)
		save_game()

func is_quest_complete(quest_id: String) -> bool:
	return quest_id in completed_quests

func get_tribe_data(tribe: String) -> Dictionary:
	return TRIBES.get(tribe, {})

func get_avatars_for_tribe(tribe: String) -> Array:
	return AVATARS.get(tribe, [])

func get_avatar_data(tribe: String, avatar_key: String) -> Dictionary:
	for av in AVATARS.get(tribe, []):
		if av["key"] == avatar_key:
			return av
	return {}

func get_stone_count() -> int:
	return stones.size()

func all_stones_collected() -> bool:
	return stones.size() >= 12

# ─────────────────────────────────────────────────────────────────────────────
# SAVE / LOAD  –  JSON  –  "Write them on the doorframes" – Deuteronomy 6:9
# ─────────────────────────────────────────────────────────────────────────────
func save_game() -> void:
	var data: Dictionary = {
		"selected_tribe":   selected_tribe,
		"selected_avatar":  selected_avatar,
		"player_name":      player_name,
		"stones":           stones,
		"memorized_verses": memorized_verses,
		"completed_quests": completed_quests,
		"journal_entries":  journal_entries,
		"heart_badges":     heart_badges,
		"treasures_found":  treasures_found,
		"world_positions":  world_positions
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		save_completed.emit()
	else:
		push_error("[TwelveStones] Could not open save file for writing: " + SAVE_PATH)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("[TwelveStones] Could not open save file for reading: " + SAVE_PATH)
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_error("[TwelveStones] Save file JSON is invalid.")
		return
	var data: Dictionary = parsed
	selected_tribe   = data.get("selected_tribe",   "")
	selected_avatar  = data.get("selected_avatar",  "")
	player_name      = data.get("player_name",      "Child")
	stones           = Array(data.get("stones",           []), TYPE_STRING, "", null)
	memorized_verses = Array(data.get("memorized_verses", []), TYPE_STRING, "", null)
	completed_quests = Array(data.get("completed_quests", []), TYPE_STRING, "", null)
	journal_entries  = data.get("journal_entries",  {})
	heart_badges     = Array(data.get("heart_badges",     []), TYPE_STRING, "", null)
	var tf_raw = data.get("treasures_found", [])
	if tf_raw is Array:
		treasures_found = Array(tf_raw, TYPE_STRING, "", null)
	world_positions  = data.get("world_positions",  {})

# ─────────────────────────────────────────────────────────────────────────────
# MULTIPLAYER SYNC  –  "May they be brought to complete unity" – John 17:23
# ─────────────────────────────────────────────────────────────────────────────
func _on_peer_connected(id: int) -> void:
	rpc_id(id, "receive_sync", selected_tribe, selected_avatar, stones, memorized_verses)

@rpc("any_peer", "call_remote", "reliable")
func receive_sync(tribe: String, avatar: String,
				  s: Array, v: Array) -> void:
	# This is called on the host when a new peer joins — store their data
	# Full cross-peer sync is handled in MultiplayerLobby
	pass

@rpc("any_peer", "call_remote", "reliable")
func receive_data(tribe: String, avatar: String, s: Array, v: Array) -> void:
	# Legacy compatibility — kept for older saved sessions
	selected_tribe   = tribe
	selected_avatar  = avatar
	stones           = Array(s, TYPE_STRING, "", null)
	memorized_verses = Array(v, TYPE_STRING, "", null)
