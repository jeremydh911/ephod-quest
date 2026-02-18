extends Control
func tribe_mini():
	# Example for Reuben
	var taps = 0
	var timer = Timer.new()
	timer.timeout.connect(func(): taps += 1; if taps >= 5: unlock_stone())
	add_child(timer)
	timer.start(1.0)
	
	# Judah roar
	var rhythm = [0.5, 1.0, 0.5]
	# ... Add similar for all tribes as per previous

func unlock_stone():
	# Unlock logic
	pass
