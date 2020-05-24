package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.List
import java.util.Map
import org.eclipse.debug.core.model.IStackFrame
import org.eclipse.debug.core.model.IVariable
import org.eclipse.draw2d.ConnectionLayer
import org.eclipse.draw2d.FreeformLayer
import org.eclipse.draw2d.FreeformLayout
import org.eclipse.draw2d.MarginBorder
import org.eclipse.draw2d.ShortestPathConnectionRouter
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.LayerConstants
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.gef.editpolicies.RootComponentEditPolicy
import org.eclipse.gef.editpolicies.XYLayoutEditPolicy
import org.eclipse.gef.requests.ChangeBoundsRequest
import org.eclipse.gef.requests.CreateRequest
import org.uqbar.project.wollok.debugger.model.WollokVariable
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.model.StaticDiagram
import org.uqbar.project.wollok.ui.diagrams.classes.model.commands.MoveOrResizeCommand

import static extension org.uqbar.project.wollok.ui.diagrams.dynamic.parts.DynamicDiagramUtils.*

/**
 * 
 * @author jfernandes
 */
abstract class AbstractStackFrameEditPart<T> extends AbstractGraphicalEditPart implements PropertyChangeListener {

	override activate() {
		if (!active) {
			super.activate
		}
	}

	override createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new RootComponentEditPolicy)
		installEditPolicy(EditPolicy.LAYOUT_ROLE, new ShapesXYLayoutEditPolicy)
	}
	
	override createFigure() {
		new FreeformLayer => [
			border = new MarginBorder(3)
			layoutManager = new FreeformLayout

			val connLayer = getLayer(LayerConstants.CONNECTION_LAYER) as ConnectionLayer
			connLayer.connectionRouter = new ShortestPathConnectionRouter(it)
		]
	}

	override deactivate() {
		if (active) {
			super.deactivate
		}
	}

	abstract def T getModelElement()
	
	abstract def List<IVariable> getVariables()

	override List<VariableModel> getModelChildren() {
		// Obtaining all non-null values
		//   That's because repeated objects are received as null and recreated
		//     in order to avoid an infinite loop cycle
		//   And to distinguish root wko references we need to get the real value 
		val allVariables = <IVariable>newArrayList 
		this.variables.traverseNonNullVariables(allVariables)
		
		// Creating root connections
		val Map<IVariable, VariableModel> mapVariables = (this.variables.fold(newHashMap()) [ resultingMap, variable |
			val variableModel = VariableModel.getVariableModelFor(variable, 0)
			if (variable.shouldShowRootArrow(allVariables)) {
				new Connection(variable.name, null, variableModel, RelationType.ASSOCIATION)
			}
			resultingMap.put(variable, variableModel)
			resultingMap
		])
		
		// Creating rest of connections
		mapVariables.values.<VariableModel>clone.forEach[model|model.createConnections(mapVariables)]
		mapVariables.values.toList
	}

	override propertyChange(PropertyChangeEvent evt) {
		val prop = evt.propertyName
		if (StaticDiagram.CHILD_ADDED_PROP == prop || StaticDiagram.CHILD_REMOVED_PROP == prop)
			refreshChildren
	}

}

class StackFrameEditPart extends AbstractStackFrameEditPart<IStackFrame> implements PropertyChangeListener {
	
	override getModelElement() { model as IStackFrame }
	
	override getVariables() {
		modelElement.variables
	}
	
}

/**
 * 
 * @author dodain
 */
class VariablesEditPart extends AbstractStackFrameEditPart<List<XDebugStackFrameVariable>> implements PropertyChangeListener {

	override getModelElement() { model as List<XDebugStackFrameVariable> }
	
	override getVariables() {
		modelElement.map [ new WollokVariable(null, it) ]
	}

}

class ShapesXYLayoutEditPolicy extends XYLayoutEditPolicy {
	override createChangeConstraintCommand(ChangeBoundsRequest request, EditPart child, Object constraint) {
		if (child instanceof ValueEditPart && constraint instanceof Rectangle)
			// return a command that can move and/or resize a Shape
			new MoveOrResizeCommand(child.model as Shape, request, constraint as Rectangle)
		else
			super.createChangeConstraintCommand(request, child, constraint)
	}

	override protected createChildEditPolicy(EditPart child) {
		super.createChildEditPolicy(child)
	}

	override createChangeConstraintCommand(EditPart child, Object constraint) {
		null
	}

	override getCreateCommand(CreateRequest request) {
		null
	}

}
