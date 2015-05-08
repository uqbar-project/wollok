package org.uqbar.project.wollok.ui.diagrams.objects.parts

import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPartFactory
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.parts.ConnectionEditPart

/**
 * 
 * @author jfernandes
 */
class ObjectDiagramEditPartFactory implements EditPartFactory {

	override createEditPart(EditPart context, Object modelElement) {
		if (modelElement == null) return null
		getPartForElement(modelElement) => [
			model = modelElement
		]
	}

	def dispatch getPartForElement(Object modelElement) {
		throw new RuntimeException("Can't create part for model element: " + (if (modelElement != null) modelElement.class.name else "null"))
	}
	
	def dispatch getPartForElement(IStackFrame it) { new StackFrameEditPart }
	def dispatch getPartForElement(VariableModel it) { new ValueEditPart }
	def dispatch getPartForElement(Connection it) { new ConnectionEditPart }

}