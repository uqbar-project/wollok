package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.gef.EditPolicy
import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.view.WMethodFigure
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * Edit part for methods
 * 
 * @author jfernandes
 */
class MethodEditPart extends AbstractLanguageElementEditPart {

	def getCastedModel() { model as WMethodDeclaration }
	override getLanguageElement() { castedModel }
	
	override protected createFigure() { 
		new WMethodFigure(castedModel) => [
			abstract = castedModel.abstract
		]
	}
	
	override protected createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new ComponentEditPolicy {})
	}
	
}