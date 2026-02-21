@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin

# Custom inspector plugin for AnimationPlayer
class SimpleInspectorPlugin extends EditorInspectorPlugin:

	var animation_player: AnimationPlayer
	var animation_list: PackedStringArray

	func _can_handle(object: Object) -> bool:
		if object is AnimationPlayer:
			animation_player = object as AnimationPlayer
			animation_list = animation_player.get_animation_list()
			return true
		else:
			animation_player = null
			return false

	func _parse_begin(object: Object) -> void:
		# Dropdown menu for selecting an animation
		var drop_down: OptionButton = OptionButton.new()
		drop_down.text = "Select Animation"
		var anim_list: PackedStringArray = animation_player.get_animation_list()
		for i in range(anim_list.size()):
			drop_down.add_item(anim_list[i])
		add_custom_control(drop_down)

		# Button to remove tracks referencing non-existent bones
		var button: Button = Button.new()
		button.text = "Clean Unused Animation Tracks"
		button.pressed.connect(_on_button_pressed.bind(drop_down))
		add_custom_control(button)

	func _on_button_pressed(drop_down: OptionButton) -> void:
		# Check if any animation exists
		if animation_list.is_empty():
			print_rich("[color=red]Error:[/color] No animations in AnimationPlayer")
			return

		var selected_idx: int = drop_down.selected
		if selected_idx < 0 or selected_idx >= animation_list.size():
			print_rich("[color=red]Error:[/color] No animation selected")
			return

		var animation_name: String = animation_list[selected_idx]
		if not animation_player.has_animation(animation_name):
			print_rich("[color=red]Error:[/color] Animation '%s' not found" % animation_name)
			return

		var anim: Animation = animation_player.get_animation(animation_name)
		var track_count: int = anim.get_track_count()
		if track_count == 0:
			print_rich("[color=yellow]Warning:[/color] Animation '%s' has no tracks" % animation_name)
			return

		# Get the root node used for resolving track paths
		var root: Node = animation_player.get_node(animation_player.root_node)
		if not root:
			print_rich("[color=red]Error:[/color] Animation root node not found")
			return

		# Cache bone names per skeleton for performance
		var bone_cache: Dictionary = {}
		var removed_count: int = 0

		# Iterate backwards to avoid index shift when removing tracks
		for track_idx in range(track_count - 1, -1, -1):
			var track_path: NodePath = anim.track_get_path(track_idx)
			var bone_name: String = track_path.get_concatenated_subnames()
			# Skip tracks that are not bone-related (no subname)
			if bone_name.is_empty():
				continue

			var node_path_str: String = String(track_path.get_concatenated_names())
			if node_path_str.is_empty():
				continue

			# Get the target node relative to the animation root
			var target: Node = root.get_node(node_path_str)
			if not target or not (target is Skeleton3D):
				continue

			var skeleton: Skeleton3D = target as Skeleton3D

			# Cache bone names for this skeleton if not already done
			if not bone_cache.has(skeleton):
				var names: PackedStringArray = PackedStringArray()
				for i in skeleton.get_bone_count():
					names.append(skeleton.get_bone_name(i))
				bone_cache[skeleton] = names

			# Retrieve cached bone names
			var bone_names: PackedStringArray = bone_cache[skeleton]

			# Remove track if bone name not found in skeleton
			if bone_name not in bone_names:
				anim.remove_track(track_idx)
				removed_count += 1
				print_rich("Track [color=green]%s[/color] is removed" % track_path)

		# Report results
		if removed_count > 0:
			print_rich("[color=green]Done![/color] Removed tracks: %d" % removed_count)
		else:
			print_rich("[color=yellow]Info:[/color] No tracks to remove in animation '%s'" % animation_name)

func _enter_tree() -> void:
	inspector_plugin = SimpleInspectorPlugin.new()
	add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
	inspector_plugin = null
