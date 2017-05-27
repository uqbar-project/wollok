package org.uqbar.project.wollok.ui.diagrams.classes;

import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.EditPartViewer
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.IMenuManager
import org.eclipse.ui.actions.ActionFactory

import static org.eclipse.gef.ui.actions.GEFActionConstants.*
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.DeleteAssociationAction

/**
 * 
 * @author jfernandes
 */
class StaticDiagramEditorContextMenuProvider extends ContextMenuProvider {
	ActionRegistry actionRegistry

	new(EditPartViewer viewer, ActionRegistry registry) {
		super(viewer)
		actionRegistry = registry
	}

	override buildContextMenu(IMenuManager it) {
		addStandardActionGroups(it)

//		appendToGroup(GROUP_UNDO, getAction(ActionFactory.UNDO.id))
//		appendToGroup(GROUP_UNDO, getAction(ActionFactory.REDO.id))
		
		val IAction actionDelete = getAction(ActionFactory.DELETE.id)
		if (actionDelete !== null) {
			appendToGroup(GROUP_EDIT, actionDelete)
		}
	}

	def getAction(String actionId) {
		actionRegistry.getAction(actionId)
	}

}
