@tool
extends EditorPlugin

var undo_redo : EditorUndoRedoManager = get_undo_redo()


func _shortcut_input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		if (event.shift_pressed and event.alt_pressed) or event.ctrl_pressed:
			return
		
		if event.alt_pressed: # Show all nodes
			undo_redo.create_action("Set visible")
			show_all_visible_nodes(get_editor_interface().get_edited_scene_root())
			undo_redo.commit_action()
			
			get_viewport().set_input_as_handled()
			return
		
		var selected_nodes : Array[Node] = get_editor_interface().get_selection().get_selected_nodes()
		if selected_nodes.is_empty():
			return
		
		undo_redo.create_action("Set visible")
		
		if event.shift_pressed: # Hide unselected nodes
			var keep_visible := get_nodes_to_keep_visible(selected_nodes)
			hide_unselected_nodes(get_editor_interface().get_edited_scene_root(), keep_visible)
			undo_redo.commit_action()
			
			get_viewport().set_input_as_handled()
			return
		
		
		# Hide selected nodes
		for selected in selected_nodes:
			if not ("visible" in selected):
				continue
			
			var root : Node = get_editor_interface().get_edited_scene_root()
			if selected == root:
				undo_redo.add_do_property(selected, "visible", !selected.visible)
				undo_redo.add_undo_property(selected, "visible", selected.visible)
				continue
			
			var current : Node
			current = selected.get_parent()
			
			while current:
				if "visible" in current and not selected.visible and not current in selected_nodes:
					undo_redo.add_do_property(current, "visible", true)
					undo_redo.add_undo_property(current, "visible", current.visible)
				if current != root:
					current = current.get_parent()
				else:
					break
			
			undo_redo.add_do_property(selected, "visible", !selected.visible)
			undo_redo.add_undo_property(selected, "visible", selected.visible)
		
		undo_redo.commit_action()
		
		get_viewport().set_input_as_handled()


func show_all_visible_nodes(node : Node) -> void:
	if "visible" in node:
		undo_redo.add_do_property(node, "visible", true)
		undo_redo.add_undo_property(node, "visible", node.visible)
	var root : Node = get_editor_interface().get_edited_scene_root()
	for child in node.get_children():
		if child.owner == root:
			show_all_visible_nodes(child)


func get_nodes_to_keep_visible(selected_nodes: Array[Node]) -> Array[Node]:
	var keep_visible : Array[Node]
	var root := get_editor_interface().get_edited_scene_root()
	for node in selected_nodes:
		while node:
			if node.owner == root or node == root:
				undo_redo.add_do_property(node, "visible", true)
				undo_redo.add_undo_property(node, "visible", node.visible)
				keep_visible.append(node)
			if node == root:
				break
			node = node.get_parent()
	return keep_visible


func hide_unselected_nodes(node: Node, keep_visible: Array[Node]) -> void:
	if "visible" in node and not node in keep_visible:
		undo_redo.add_do_property(node, "visible", false)
		undo_redo.add_undo_property(node, "visible", node.visible)
	var root := get_editor_interface().get_edited_scene_root()
	for child in node.get_children():
		if child.owner == root:
			hide_unselected_nodes(child, keep_visible)
