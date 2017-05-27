package org.uqbar.project.wollok.ui.diagrams.classes;

import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.EditPartViewer
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.IMenuManager
import org.eclipse.ui.actions.ActionFactory

import static org.eclipse.gef.ui.actions.GEFActionConstants.*
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.DeleteAssociationAction
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.AbstractDeleteElementAction

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
		addToGroup(GROUP_EDIT, AbstractDeleteElementAction.DELETE_ASSOCIATION)		
		addToGroup(GROUP_EDIT, AbstractDeleteElementAction.HIDE_CLASS)
	}

	def getAction(String actionId) {
		actionRegistry.getAction(actionId)
	}
	
	def void addToGroup(String group, String actionId) {
		val IAction action = getAction(actionId)
		if (action !== null) {
			appendToGroup(group, action)
		}
	}

}
