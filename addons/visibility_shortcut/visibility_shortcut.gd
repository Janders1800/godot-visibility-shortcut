@tool
extends EditorPlugin


var undo_redo : EditorUndoRedoManager = get_undo_redo()


func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and Input.is_key_pressed(KEY_H):
		var selected_nodes : Array[Node] = get_editor_interface().get_selection().get_selected_nodes()
		
		undo_redo.create_action("Set visible")
		for node in selected_nodes:
			if node.has_method("hide"):
				if node.visible:
					# Hide node.
					undo_redo.add_do_property(node, "visible", false)
					undo_redo.add_undo_property(node, "visible", true)
				else:
					# Show node.
					undo_redo.add_do_property(node, "visible", true)
					undo_redo.add_undo_property(node, "visible", false)
		undo_redo.commit_action()

