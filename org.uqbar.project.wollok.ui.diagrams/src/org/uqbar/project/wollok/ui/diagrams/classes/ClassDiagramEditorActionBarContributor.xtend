package org.uqbar.project.wollok.ui.diagrams.classes;

import org.eclipse.gef.ui.actions.ActionBarContributor
import org.eclipse.gef.ui.actions.DeleteRetargetAction
import org.eclipse.gef.ui.actions.RedoRetargetAction
import org.eclipse.gef.ui.actions.UndoRetargetAction
import org.eclipse.jface.action.IToolBarManager
import org.eclipse.ui.actions.ActionFactory

/**
 * 
 * @author jfernandes
 */
class ClassDiagramEditorActionBarContributor extends ActionBarContributor {

	override buildActions() {
		#[
			new DeleteRetargetAction,
			new UndoRetargetAction,
			new RedoRetargetAction
		]
		.forEach[
			addRetargetAction
		]
	}

	override contributeToToolBar(IToolBarManager toolBarManager) {
		#[
			ActionFactory.UNDO, 
			ActionFactory.REDO
		].forEach[
			toolBarManager.add(getAction(id))
		]
	}

	override declareGlobalActionKeys() {
		// currently none
	}

}