package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPartFactory
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection

/**
 * 
 * @author jfernandes
 */
class ClassDiagramEditPartFactory implements EditPartFactory {

	override createEditPart(EditPart context, Object modelElement) {
		getPartForElement(modelElement) => [
			model = modelElement
		]
	}

	def dispatch getPartForElement(Object modelElement) {
		throw new RuntimeException("Can't create part for model element: " + (if (modelElement != null) modelElement.class.name else "null"))
	}
	
	def dispatch getPartForElement(ClassDiagram it) { new ClassDiagramEditPart }
	def dispatch getPartForElement(ClassModel it) { new ClassEditPart }
	def dispatch getPartForElement(Connection it) { new ConnectionEditPart }

}