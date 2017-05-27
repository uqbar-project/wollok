package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.ui.actions.DeleteAction
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.actions.ActionFactory
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart

/**
 * 
 * Contextual menu action for deleting an association
 * 
 * @author: dodain
 * 
 */
class DeleteAssociationAction extends DeleteAction {
	
	StaticDiagramConfiguration configuration
	
	new(IWorkbenchPart part, GraphicalViewer viewer, StaticDiagramConfiguration configuration) {
		super(part)
		id = ActionFactory.DELETE.id
		text = Messages.StaticDiagram_DeleteAssociation
		// Hack: Manually added nodes and connections selections because it is not working
		viewer.addSelectionChangedListener([ event | 
			selection = event.selection
		])
		this.configuration = configuration
	}
	
	override protected calculateEnabled() {
		!selectedObjects.empty && selectedObjects.forall [ it instanceof AssociationConnectionEditPart ]
	}
	
	override run() {
		val _objects = selectedObjects // attention! after running from superclass selectedObjects change!
		super.run()
		_objects.forEach [ 
			val connection = it as AssociationConnectionEditPart
			configuration.removeAssociation(connection.castedModel.source as AbstractModel, 
				connection.castedModel.target as AbstractModel)
		]
	}
	
}