package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.gef.EditPolicy
import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.view.WAttributteFigure
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

/**
 * 
 * Edit part for instance variables
 * 
 * @author jfernandes
 */
class InstanceVariableEditPart extends AbstractLanguageElementEditPart {
	
	def getCastedModel() { model as WVariableDeclaration }
	override getLanguageElement() { castedModel }
	
	override protected createFigure() {
		new WAttributteFigure(castedModel)
	}
	
	override protected createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new ComponentEditPolicy {})
	}
	
}