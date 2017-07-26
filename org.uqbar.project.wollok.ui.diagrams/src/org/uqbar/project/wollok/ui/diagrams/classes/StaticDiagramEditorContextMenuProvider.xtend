package org.uqbar.project.wollok.ui.diagrams.classes;

import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.EditPartViewer
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.IMenuManager
import org.eclipse.ui.actions.ActionFactory

import static org.eclipse.gef.ui.actions.GEFActionConstants.*
import org.uqbar.project.wollok.ui.diagrams.classes.actionbar.ShowHiddenPartsElementAction

/**
 * 
 * Contextual menu (right-click) for every element in the diagram
 * 
 * @author jfernandes
 * @author dodain      Added "Delete" action for nodes, relationships, variables & methods
 * 
 */
class StaticDiagramEditorContextMenuProvider extends ContextMenuProvider {
	ActionRegistry actionRegistry

	new(EditPartViewer viewer, ActionRegistry registry) {
		super(viewer)
		actionRegistry = registry
	}

	override buildContextMenu(IMenuManager it) {
		addStandardActionGroups(it)
		addToGroup(GROUP_EDIT, ActionFactory.DELETE.id)
		addToGroup(GROUP_EDIT, ShowHiddenPartsElementAction.SHOW_HIDDEN_PART_ELEMENT_ID)
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
