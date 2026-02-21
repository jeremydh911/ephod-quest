extends Node
# ─────────────────────────────────────────────────────────────────────────────
# VerseVault.gd  –  Twelve Stones / Ephod Quest
# Collectible verse library — 12 main quest verses + 12 nature verses.
# "Your word I have hidden in my heart" – Psalm 119:11
# ─────────────────────────────────────────────────────────────────────────────

signal vault_opened
signal verse_flipped(entry: Dictionary)

# ─────────────────────────────────────────────────────────────────────────────
# VAULT CATALOGUE
# Each entry: { tribe, ref, text, type, nature_fact, nature_verse_ref, nature_verse }
# type = "quest" | "nature"
# ─────────────────────────────────────────────────────────────────────────────
const VAULT: Dictionary = {
	"reuben": [
		{
			"tribe": "reuben", "type": "quest",
			"ref": "Proverbs 3:5-6",
			"text": "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight."
		},
		{
			"tribe": "reuben", "type": "bonus",
			"ref": "Genesis 49:3-4",
			"text": "Reuben, you are my firstborn, my might, and the firstfruits of my strength, preeminent in dignity and preeminent in power. Unstable as water, you shall not have preeminence..."
		},
		{
			"tribe": "reuben", "type": "nature",
			"ref": "2 Corinthians 5:17",
			"text": "Therefore, if anyone is in Christ, the new creation has come: the old has gone, the new is here!",
			"fact": "Butterflies taste with their feet. When they land on a flower, tiny sensors in their feet instantly tell them if it is sweet or bitter — they experience the world through where they stand."
		}
	],
	"simeon": [
		{
			"tribe": "simeon", "type": "quest",
			"ref": "Psalm 46:10",
			"text": "Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth."
		},
		{
			"tribe": "simeon", "type": "bonus",
			"ref": "Genesis 49:5-7",
			"text": "Simeon and Levi are brothers—their swords are weapons of violence. Let me not enter their council, let me not join their assembly, for they have killed men in their anger and hamstrung oxen as they pleased..."
		},
		{
			"tribe": "simeon", "type": "nature",
			"ref": "John 10:27",
			"text": "My sheep listen to my voice; I know them, and they follow me.",
			"fact": "Sheep can recognise up to 50 other sheep faces and remember them for years. They also know the voice of their own shepherd and will not follow a stranger — even in a large, noisy flock."
		}
	],
	"levi": [
		{
			"tribe": "levi", "type": "quest",
			"ref": "Matthew 5:16",
			"text": "In the same way, let your light shine before others, that they may see your good deeds and glorify your Father in heaven."
		},
		{
			"tribe": "levi", "type": "bonus",
			"ref": "Numbers 18:1",
			"text": "The LORD said to Aaron, 'You, your sons and your family are to bear the responsibility for offenses connected with the sanctuary, and you and your sons alone are to bear the responsibility for offenses connected with the priesthood.'"
		},
		{
			"tribe": "levi", "type": "nature",
			"ref": "Daniel 12:3",
			"text": "Those who are wise will shine like the brightness of the heavens, and those who lead many to righteousness, like the stars for ever and ever.",
			"fact": "Fireflies produce 'cold light' — nearly 100% of their energy output becomes visible light with almost no heat wasted. Scientists call this bioluminescence and are studying it to design more efficient lighting."
		}
	],
	"judah": [
		{
			"tribe": "judah", "type": "quest",
			"ref": "Psalm 100:1-2",
			"text": "Shout for joy to the LORD, all the earth. Worship the LORD with gladness; come before him with joyful songs."
		},
		{
			"tribe": "judah", "type": "bonus",
			"ref": "Genesis 49:8-10",
			"text": "Judah, your brothers will praise you; your hand will be on the neck of your enemies; your father's sons will bow down to you. You are a lion's cub, Judah; you return from the prey, my son. Like a lion he crouches and lies down, like a lioness—who dares to rouse him? The scepter will not depart from Judah, nor the ruler's staff from between his feet, until he to whom it belongs shall come and the obedience of the nations shall be his."
		},
		{
			"tribe": "judah", "type": "nature",
			"ref": "Revelation 5:5",
			"text": "See, the Lion of the tribe of Judah, the Root of David, has triumphed.",
			"fact": "A lion's roar can be heard up to 8 km (5 miles) away. At dawn the male lion roars to mark safe territory for his pride — the sound travels furthest in the cool morning air. The whole pride rests more peacefully knowing he has spoken."
		}
	],
	"dan": [
		{
			"tribe": "dan", "type": "quest",
			"ref": "Proverbs 2:6",
			"text": "For the LORD gives wisdom; from his mouth come knowledge and understanding."
		},
		{
			"tribe": "dan", "type": "bonus",
			"ref": "Genesis 49:16-18",
			"text": "Dan will provide justice for his people as one of the tribes of Israel. Dan will be a snake by the roadside, a viper along the path, that bites the horse's heels so that its rider tumbles backward. I wait for your salvation, LORD."
		},
		{
			"tribe": "dan", "type": "nature",
			"ref": "Isaiah 40:31",
			"text": "But those who hope in the LORD will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.",
			"fact": "Eagles have five-times-sharper vision than humans. Their eyes contain two foveas (instead of our one), giving them both wide-angle and telescopic view simultaneously. An eagle can spot a rabbit from nearly 3 km away. They also periodically replace old feathers — a slow, patient renewal that makes them stronger."
		}
	],
	"naphtali": [
		{
			"tribe": "naphtali", "type": "quest",
			"ref": "Isaiah 52:7",
			"text": "How beautiful on the mountains are the feet of those who bring good news, who proclaim peace, who bring good tidings, who proclaim salvation."
		},
		{
			"tribe": "naphtali", "type": "bonus",
			"ref": "Genesis 49:21",
			"text": "Naphtali is a doe set free that bears beautiful fawns."
		},
		{
			"tribe": "naphtali", "type": "nature",
			"ref": "Psalm 147:15",
			"text": "He sends his command to the earth; his word runs swiftly.",
			"fact": "Hummingbirds beat their wings up to 80 times per second — so fast the human eye sees only a blur. They are the only birds that can truly hover and fly backward, making them the most agile fliers in creation."
		}
	],
	"gad": [
		{
			"tribe": "gad", "type": "quest",
			"ref": "Hebrews 12:1",
			"text": "Let us run with perseverance the race marked out for us, fixing our eyes on Jesus, the pioneer and perfecter of faith."
		},
		{
			"tribe": "gad", "type": "bonus",
			"ref": "Genesis 49:19",
			"text": "Gad will be attacked by a band of raiders, but he will attack them at their heels."
		},
		{
			"tribe": "gad", "type": "nature",
			"ref": "Psalm 52:8",
			"text": "But I am like an olive tree flourishing in the house of God; I trust in God's unfailing love for ever and ever.",
			"fact": "Olive trees can live for more than 2 000 years. Some of the ancient olive trees still standing in the Garden of Gethsemane in Jerusalem may have been alive during the time of Jesus. They produce fruit year after year, generation after generation."
		}
	],
	"asher": [
		{
			"tribe": "asher", "type": "quest",
			"ref": "Luke 9:16",
			"text": "Taking the five loaves and the two fish and looking up to heaven, he gave thanks and broke them. Then he gave them to the disciples to distribute to the people."
		},
		{
			"tribe": "asher", "type": "bonus",
			"ref": "Genesis 49:20",
			"text": "Asher's food will be rich; he will provide delicacies fit for a king."
		},
		{
			"tribe": "asher", "type": "nature",
			"ref": "Proverbs 16:24",
			"text": "Gracious words are a honeycomb, sweet to the soul and healing to the bones.",
			"fact": "Honeybees communicate the exact location of flowers using a 'waggle dance'. The angle of the dance shows the direction relative to the sun, and the duration encodes the distance. It is one of the most sophisticated communication systems in the animal kingdom."
		}
	],
	"issachar": [
		{
			"tribe": "issachar", "type": "quest",
			"ref": "1 Chronicles 12:32",
			"text": "From Issachar, men who understood the times and knew what Israel should do — 200 chiefs, with all their relatives under their command."
		},
		{
			"tribe": "issachar", "type": "bonus",
			"ref": "Genesis 49:14-15",
			"text": "Issachar is a rawboned donkey lying down among the sheep pens. When he sees how good is his resting place and how pleasant is his land, he will bend his shoulder to the burden and submit to forced labor."
		},
		{
			"tribe": "issachar", "type": "nature",
			"ref": "Ecclesiastes 3:1",
			"text": "There is a time for everything, and a season for every activity under the heavens.",
			"fact": "Monarch butterflies migrate up to 4 500 km (2 800 miles) and return each year to the exact same grove of trees their great-grandparents used — even though no individual butterfly has ever made the journey before. Scientists believe they navigate using the sun's position and the Earth's magnetic field."
		}
	],
	"zebulun": [
		{
			"tribe": "zebulun", "type": "quest",
			"ref": "Romans 15:7",
			"text": "Accept one another, then, just as Christ accepted you, in order to bring praise to God."
		},
		{
			"tribe": "zebulun", "type": "bonus",
			"ref": "Genesis 49:13",
			"text": "Zebulun will live by the seashore and become a haven for ships; his border will extend toward Sidon."
		},
		{
			"tribe": "zebulun", "type": "nature",
			"ref": "Ecclesiastes 4:9",
			"text": "Two are better than one, because they have a good return for their labor: if either of them falls down, one can help the other up.",
			"fact": "Clownfish and sea anemones share one of nature's most famous partnerships. The fish cleans the anemone and drives away predators; the anemone's stinging tentacles protect the fish. Neither could thrive as well alone. Creation is full of designed friendships."
		}
	],
	"joseph": [
		{
			"tribe": "joseph", "type": "quest",
			"ref": "Genesis 50:20",
			"text": "You intended to harm me, but God intended it for good to accomplish what is now being done, the saving of many lives."
		},
		{
			"tribe": "joseph", "type": "bonus",
			"ref": "Genesis 49:22-26",
			"text": "Joseph is a fruitful vine, a fruitful vine near a spring, whose branches climb over a wall. With bitterness archers attacked him; they shot at him with hostility. But his bow remained steady, his strong arms stayed limber, because of the hand of the Mighty One of Jacob, because of the Shepherd, the Rock of Israel..."
		},
		{
			"tribe": "joseph", "type": "nature",
			"ref": "Romans 8:28",
			"text": "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
			"fact": "Pearls are formed when an oyster surrounds an irritant — like a grain of sand — with layer after layer of nacre (mother-of-pearl). What started as discomfort becomes, over years of patient coating, one of the most beautiful objects in nature."
		}
	],
	"benjamin": [
		{
			"tribe": "benjamin", "type": "quest",
			"ref": "Deuteronomy 33:12",
			"text": "Let the beloved of the LORD rest secure in him, for he shields him all day long, and the one the LORD loves rests between his shoulders."
		},
		{
			"tribe": "benjamin", "type": "bonus",
			"ref": "Genesis 49:27",
			"text": "Benjamin is a ravenous wolf; in the morning he devours the prey, in the evening he divides the plunder."
		},
		{
			"tribe": "benjamin", "type": "nature",
			"ref": "Zephaniah 3:17",
			"text": "The LORD your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.",
			"fact": "Wolf pups are raised not just by their parents, but by the entire pack. Every adult wolf helps feed, protect, and play with the young. The smallest and weakest pup receives as much care as the strongest — no pup is left alone."
		}
	]
}

# ─────────────────────────────────────────────────────────────────────────────
# RUNTIME API
# ─────────────────────────────────────────────────────────────────────────────

## Return all entries the player has unlocked (stone collected or verse memorized)
func get_unlocked_entries() -> Array:
	var result: Array = []
	for tribe_entries in VAULT.values():
		for entry in tribe_entries:
			var tribe: String = entry.get("tribe", "")
			if tribe in Global.stones or entry.get("ref","") in Global.memorized_verses:
				result.append(entry)
	return result

## Return a specific tribe's quest verse entry
func get_quest_verse(tribe: String) -> Dictionary:
	if tribe in VAULT:
		for entry in VAULT[tribe]:
			if entry.get("type") == "quest":
				return entry
	return {}

## Return a specific tribe's nature verse entry
func get_nature_entry(tribe: String) -> Dictionary:
	if tribe in VAULT:
		for entry in VAULT[tribe]:
			if entry.get("type") == "nature":
				return entry
	return {}

## Return all bonus verses for a tribe
func get_bonus_verses(tribe: String) -> Array:
	var result: Array = []
	if tribe in VAULT:
		for entry in VAULT[tribe]:
			if entry.get("type") == "bonus":
				result.append(entry)
	return result

## Check if a verse reference has been memorised
func is_memorized(ref: String) -> bool:
	return ref in Global.memorized_verses

## Return ALL entries (used by VerseVaultScene journal — shows even locked entries)
func get_all_entries() -> Array:
	var result: Array = []
	for tribe_entries in VAULT.values():
		result.append_array(tribe_entries)
	return result
