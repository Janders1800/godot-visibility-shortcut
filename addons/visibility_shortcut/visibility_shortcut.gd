@tool
extends EditorPlugin


var undo_redo : EditorUndoRedoManager = get_undo_redo()

func _shortcut_input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_H:
		if (event.shift_pressed and event.alt_pressed) or event.ctrl_pressed:
			return
		
		undo_redo.create_action("Set visible")
		
		if event.alt_pressed: # Show all nodes
			var all_nodes : Array[Node] = get_all_nodes(get_editor_interface().get_edited_scene_root())
			for node in all_nodes:
				if "visible" in node:
					undo_redo.add_do_property(node, "visible", true)
					undo_redo.add_undo_property(node, "visible", false)
			undo_redo.commit_action()
			
			get_viewport().set_input_as_handled()
			return
		
		if event.shift_pressed: # Hide unselected nodes
			var all_nodes : Array[Node] = get_all_nodes(get_editor_interface().get_edited_scene_root())
			var selected_nodes : Array[Node] = get_editor_interface().get_selection().get_selected_nodes()
			var unselected_nodes : Array[Node]
			var forviden : Array[Node]
			
			for node in all_nodes:
				for selected in selected_nodes:
					if node.is_ancestor_of(selected) or selected.is_ancestor_of(node):
						forviden.append(node)
			
			for node in all_nodes:
				if "visible" in node and not node in selected_nodes:
					for selected in selected_nodes:
						if not selected.is_ancestor_of(node) and not node.is_ancestor_of(selected):
							if not node in forviden:
								unselected_nodes.append(node)
			
			for node in unselected_nodes:
				if "visible" in node:
					undo_redo.add_do_property(node, "visible", false)
					undo_redo.add_undo_property(node, "visible", true)
			undo_redo.commit_action()
			
			get_viewport().set_input_as_handled()
			return
		
		# Hide selected nodes
		var selected_nodes : Array[Node] = get_editor_interface().get_selection().get_selected_nodes()
		
		for node in selected_nodes:
			if "visible" in node:
				undo_redo.add_do_property(node, "visible", !node.visible)
				undo_redo.add_undo_property(node, "visible", node.visible)
		undo_redo.commit_action()
		
		get_viewport().set_input_as_handled()


func get_all_nodes(root_node: Node) -> Array[Node]:
	var all_nodes : Array[Node]
	recursive_get_nodes(root_node, all_nodes)
	return all_nodes

func recursive_get_nodes(node: Node, nodes: Array[Node]) -> void:
	nodes.append(node)
	for child in node.get_children():
		if child.owner == get_editor_interface().get_edited_scene_root():
			recursive_get_nodes(child, nodes)
