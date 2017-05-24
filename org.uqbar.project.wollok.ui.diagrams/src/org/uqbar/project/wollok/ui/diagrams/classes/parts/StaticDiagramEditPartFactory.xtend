package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPartFactory
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.MixinModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.NamedObjectModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.StaticDiagram
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

/**
 * 
 * @author jfernandes
 */
class StaticDiagramEditPartFactory implements EditPartFactory {

	override createEditPart(EditPart context, Object modelElement) {
		getPartForElement(modelElement) => [
			model = modelElement
		]
	}

	def dispatch getPartForElement(Object modelElement) {
		throw new RuntimeException("Can't create part for model element: " + (if (modelElement != null) modelElement.class.name else "null"))
	}
	
	def dispatch getPartForElement(StaticDiagram it) { new StaticDiagramEditPart }
	def dispatch getPartForElement(ClassModel it) { new ClassEditPart }
	def dispatch getPartForElement(MixinModel it) { new MixinEditPart }
	def dispatch getPartForElement(NamedObjectModel it) { new NamedObjectEditPart }
	def dispatch getPartForElement(WVariableDeclaration it) { new InstanceVariableEditPart }
	def dispatch getPartForElement(WMethodDeclaration it) { new MethodEditPart }
	
	def dispatch getPartForElement(Connection it) {
		if (it.relationType.equals(RelationType.INHERITANCE))
			return new InheritanceConnectionEditPart;
			
		if (it.relationType.equals(RelationType.ASSOCIATION))
			return new AssociationConnectionEditPart;
			
		throw new IllegalArgumentException("This connection has not been developed yet")
	}

}