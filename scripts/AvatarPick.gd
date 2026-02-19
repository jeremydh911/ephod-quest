extends Control

func _ready():
	# Connect the Confirm button to proceed to Quest1
	$Confirm.pressed.connect(func(): 
		# TODO: Store selected tribe/avatar in Global when selection UI is implemented
		var error = get_tree().change_scene_to_file("res://scenes/Quest1.tscn")
		if error != OK:
			push_error("Failed to load Quest1 scene: " + str(error))
	)

func tribe_mini():
	# Placeholder for future tribe-specific mini-games
	# Each tribe will have unique challenges to unlock stones
	pass

func unlock_stone():
	# Called when a tribe mini-game is completed
	# Will add the tribe's stone to the Global collection
	pass
