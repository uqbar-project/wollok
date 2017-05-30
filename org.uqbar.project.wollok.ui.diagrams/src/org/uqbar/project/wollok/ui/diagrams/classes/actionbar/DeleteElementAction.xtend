package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.ui.actions.DeleteAction
import org.eclipse.ui.IWorkbenchPart
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.DependencyConnectionEditPart

/**
 * 
 * Contextual menu action for 
 * - deleting an association
 * - deleting a dependency 
 * - or hiding a component 
 * from the diagram
 * 
 * @author: dodain
 * 
 */
class DeleteElementAction extends DeleteAction {

	StaticDiagramConfiguration configuration

	new(IWorkbenchPart part, GraphicalViewer viewer, StaticDiagramConfiguration configuration) {
		super(part)
		// Hack: Manually added nodes and connections selections because it is not working
		this.text = Messages.StaticDiagram_DeleteFromDiagram_Description
		viewer.addSelectionChangedListener([ event |
			selection = event.selection
		])
		this.configuration = configuration
	}

	override protected calculateEnabled() {
		!selectedObjects.empty && selectedObjects.forall [ selectedObject |
			selectedObject instanceof AssociationConnectionEditPart ||
			selectedObject instanceof AbstractMethodContainerEditPart ||
			selectedObject instanceof DependencyConnectionEditPart
		]
	}

	override run() {
		val _selectedObjects = selectedObjects // attention! after running from superclass selectedObjects change!
		super.run()
		_selectedObjects.forEach [ selectedObject |
			selectedObject.run
		]
	}

	def dispatch run(DependencyConnectionEditPart connection) {
		configuration.removeDependency(connection.castedModel.source as AbstractModel,
			connection.castedModel.target as AbstractModel)
	}

	def dispatch run(AssociationConnectionEditPart connection) {
		configuration.removeAssociation(connection.castedModel.source as AbstractModel,
			connection.castedModel.target as AbstractModel)
	}

	def dispatch run(AbstractMethodContainerEditPart component) {
		configuration.hideComponent(component.castedModel as AbstractModel)
	}

}
		