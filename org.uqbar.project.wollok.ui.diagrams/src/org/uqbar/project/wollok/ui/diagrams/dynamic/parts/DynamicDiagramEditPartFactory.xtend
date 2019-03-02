package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.util.List
import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPartFactory
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection

/**
 * 
 * @author jfernandes
 */
class DynamicDiagramEditPartFactory implements EditPartFactory {

	override createEditPart(EditPart context, Object modelElement) {
		if (modelElement === null) return null
		getPartForElement(modelElement) => [
			model = modelElement
		]
	}

	def dispatch getPartForElement(Object modelElement) {
		throw new RuntimeException("Can't create part for model element: " + (if (modelElement !== null) modelElement.class.name else "null"))
	}
	
	def dispatch getPartForElement(IStackFrame it) { new StackFrameEditPart }
	def dispatch getPartForElement(VariableModel it) { new ValueEditPart }
	def dispatch getPartForElement(Connection it) { new ReferenceConnectionEditPart  }
	def dispatch getPartForElement(List<XDebugStackFrameVariable> it) {	new VariablesEditPart }

}