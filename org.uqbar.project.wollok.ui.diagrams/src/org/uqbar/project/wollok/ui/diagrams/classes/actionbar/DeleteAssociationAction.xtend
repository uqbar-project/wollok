package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import java.net.MalformedURLException
import java.net.URL
import java.util.List
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.ui.actions.DeleteAction
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.ui.IWorkbenchPart
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart

/**
 * 
 * Contextual menu action for deleting an association
 * 
 * @author: dodain
 * 
 */
abstract class AbstractDeleteElementAction extends DeleteAction {

	public static String DELETE_ASSOCIATION = "delete_association"
	public static String HIDE_CLASS = "hide_class"

	protected StaticDiagramConfiguration configuration
	
	new(IWorkbenchPart part, GraphicalViewer viewer, StaticDiagramConfiguration configuration) {
		super(part)
		id = this.createId
		text = this.textAction
		// Hack: Manually added nodes and connections selections because it is not working
		viewer.addSelectionChangedListener([ event | 
			selection = event.selection
		])
		this.configuration = configuration
	}
	
	override protected calculateEnabled() {
		!selectedObjects.empty && selectedObjects.forall [ selectedObject | doCalculateEnabled(selectedObject) ]
	}

	override run() {
		val _objects = selectedObjects // attention! after running from superclass selectedObjects change!
		super.run()
		_objects.doRun
	}

	/** Abstract method you should implement */	
	def String createId()                               // action id
	def String getTextAction()                          // action description
	def boolean doCalculateEnabled(Object object)       // if menu is enabled
	def void doRun(List<Object> selectedObjects)        // post-run template method
	
}

class DeleteAssociationAction extends AbstractDeleteElementAction {
	
	new(IWorkbenchPart part, GraphicalViewer viewer, StaticDiagramConfiguration configuration) {
		super(part, viewer, configuration)
		try {
			imageDescriptor = ImageDescriptor.createFromFile(this.class, "/icons/association_delete.png")
		} catch (MalformedURLException e) {
			// use default delete icon
		}
	}
	
	override doCalculateEnabled(Object selectedObject) {
		selectedObject instanceof AssociationConnectionEditPart
	}
	
	override doRun(List<Object> _objects) {
		_objects.forEach [ 
			val connection = it as AssociationConnectionEditPart
			this.configuration.removeAssociation(connection.castedModel.source as AbstractModel, 
				connection.castedModel.target as AbstractModel)
		]
	}
	
	override getTextAction() {
		Messages.StaticDiagram_DeleteAssociation_Description
	}
	
	override createId() {
		DELETE_ASSOCIATION
	}
	
}

class HideComponentAction extends AbstractDeleteElementAction {
	
	new(IWorkbenchPart part, GraphicalViewer viewer, StaticDiagramConfiguration configuration) {
		super(part, viewer, configuration)
		try {
			imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.ui/icons/full/obj16/innerclass_private_obj.png"))
		} catch (MalformedURLException e) {
			// use default delete icon
		}
	}
	
	override doCalculateEnabled(Object selectedObject) {
		selectedObject instanceof AbstractMethodContainerEditPart
	}
	
	override doRun(List<Object> _objects) {
		_objects.forEach [ 
			val component = it as AbstractMethodContainerEditPart
			this.configuration.hideComponent(component.castedModel as AbstractModel)
		]
	}

	override getTextAction() {
		Messages.StaticDiagram_HideClassFromDiagram_Description
	}

	override createId() {
		HIDE_CLASS
	}
	
}