package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import java.net.URL
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.ui.actions.SelectionAction
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.ui.IWorkbenchPart
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AbstractMethodContainerEditPart

class ShowHiddenPartsElementAction extends SelectionAction {

	public static String SHOW_HIDDEN_PART_ELEMENT_ID = "Show_Hidden_Part_Element"

	StaticDiagramConfiguration configuration

	new(IWorkbenchPart part, GraphicalViewer viewer, StaticDiagramConfiguration configuration) {
		super(part)
		this.text = Messages.StaticDiagram_ShowHiddenPartsElement_Description
		// Hack: Manually added nodes and connections selections because it is not working
		viewer.addSelectionChangedListener([ event |
			selection = event.selection
		])
		this.configuration = configuration
	}

	override protected calculateEnabled() {
		!selectedObjects.empty && selectedObjects.forall [ selectedObject |
			selectedObject.shouldEnableAction
		]
	}
	
	def dispatch shouldEnableAction(Object object) {
		false
	}
	
	def dispatch shouldEnableAction(AbstractMethodContainerEditPart component) {
		configuration.hasHiddenParts(component.castedModel as AbstractModel)
	}
	
	override run() {
		selectedObjects.forEach [ selectedObject |
			val component = selectedObject as AbstractMethodContainerEditPart
			configuration.showAllPartsFrom(component.castedModel as AbstractModel)
		]
	}

	override getId() {
		SHOW_HIDDEN_PART_ELEMENT_ID
	}

	override getImageDescriptor() {
		ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.doc.user/images/org.eclipse.debug.ui/elcl16/changevariablevalue_co.png"))
	}
	
}
