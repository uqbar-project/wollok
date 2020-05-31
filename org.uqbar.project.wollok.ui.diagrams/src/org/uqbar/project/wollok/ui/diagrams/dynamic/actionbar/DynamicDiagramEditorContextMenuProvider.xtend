package org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar

import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.EditPartViewer
import org.eclipse.gef.ui.actions.ActionRegistry
import org.eclipse.jface.action.IAction
import org.eclipse.jface.action.IMenuManager
import org.eclipse.ui.actions.ActionFactory

import static org.eclipse.gef.ui.actions.GEFActionConstants.*

class DynamicDiagramEditorContextMenuProvider extends ContextMenuProvider {
	ActionRegistry actionRegistry

	new(EditPartViewer viewer, ActionRegistry registry) {
		super(viewer)
		actionRegistry = registry
	}

	override buildContextMenu(IMenuManager it) {
		addStandardActionGroups(it)
		addToGroup(GROUP_EDIT, ActionFactory.DELETE.id)
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
