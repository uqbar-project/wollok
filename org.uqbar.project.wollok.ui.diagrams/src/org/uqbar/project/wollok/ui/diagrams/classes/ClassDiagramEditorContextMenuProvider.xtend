package org.uqbar.project.wollok.ui.diagrams.classes;

import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.EditPartViewer
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.jface.action.IMenuManager
import org.eclipse.ui.actions.ActionFactory

import static org.eclipse.gef.ui.actions.GEFActionConstants.*

/**
 * @author jfernandes
 */
class ClassDiagramEditorContextMenuProvider extends ContextMenuProvider {
	ActionRegistry actionRegistry

	new(EditPartViewer viewer, ActionRegistry registry) {
		super(viewer)
		actionRegistry = registry
	}

	override buildContextMenu(IMenuManager it) {
		addStandardActionGroups(it)

		appendToGroup(GROUP_UNDO, getAction(ActionFactory.UNDO.id))
		appendToGroup(GROUP_UNDO, getAction(ActionFactory.REDO.id))
		appendToGroup(GROUP_EDIT, getAction(ActionFactory.DELETE.id))
	}

	def getAction(String actionId) {
		actionRegistry.getAction(actionId)
	}

}
