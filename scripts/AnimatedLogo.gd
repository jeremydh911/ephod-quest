extends Control
# ─────────────────────────────────────────────────────────────────────────────
# AnimatedLogo.gd – Creative Animated Intro Scene
# Captures the flavor: Tribal stones glowing, title fade-in, unity theme.
# "Behold, how good and how pleasant it is for brethren to dwell together in unity!" – Psalm 133:1
# ─────────────────────────────────────────────────────────────────────────────

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("logo_anim")
	await anim_player.animation_finished
	# Transition to MainMenu after animation
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")