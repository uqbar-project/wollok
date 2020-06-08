package org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar

import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.ui.actions.DeleteAction
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.dynamic.parts.ValueEditPart

class DeleteObjectAction extends DeleteAction {
	
	DynamicDiagramConfiguration configuration
	DynamicDiagramView view

	new(DynamicDiagramView view, GraphicalViewer viewer, DynamicDiagramConfiguration configuration) {
		super(view)
		// Hack: Manually added nodes and connections selections because it is not working
		this.text = Messages.StaticDiagram_DeleteFromDiagram_Description
		// TODO: Cambiar el mensaje
		viewer.addSelectionChangedListener([ event |
			selection = event.selection
		])
		this.configuration = configuration
		this.view = view
	}

	override protected calculateEnabled() {
		!selectedObjects.empty && selectedObjects.forall [ selectedObject |
			selectedObject instanceof ValueEditPart && 
			(selectedObject as ValueEditPart).canBeHidden
		]
	}

	override run() {
		val currentSelectedObjects = selectedObjects // attention! after running from superclass selectedObjects change!
		super.run()
		currentSelectedObjects.forEach [ selectedObject |
			selectedObject.run
		]
	}

	def run(ValueEditPart value) {
		configuration.hideObject(value.castedModel)
		view.refreshView(false)
	}

}