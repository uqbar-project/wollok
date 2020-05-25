package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.List
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.Ellipse
import org.eclipse.draw2d.EllipseAnchor
import org.eclipse.draw2d.Figure
import org.eclipse.draw2d.Label
import org.eclipse.draw2d.StackLayout
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.ConnectionEditPart
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.NodeEditPart
import org.eclipse.gef.Request
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.view.DiagramColors
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration

import static extension org.uqbar.project.wollok.ui.utils.WollokDynamicDiagramUtils.*

/**
 * 
 * @author jfernandes
 * @author dodain
 * 
 */
class ValueEditPart extends AbstractGraphicalEditPart implements PropertyChangeListener, NodeEditPart {
	ConnectionAnchor anchor
	org.eclipse.draw2d.Shape ellipse
	
	override activate() {
		if (!active) {
			super.activate
			castedModel.addPropertyChangeListener(this)
		}
	}
	
	override deactivate() {
		if (active) {
			super.deactivate
			castedModel.removePropertyChangeListener(this)
		}
	}

	override createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new ComponentEditPolicy {})
	}

	override createFigure() {
		new Figure => [
			layoutManager = new StackLayout
		
			this.ellipse = createShape() => [
				backgroundColor = colorFor(castedModel)
				lineWidth = lineWidthFor(castedModel)				
				opaque = true
			]
			add(this.ellipse)
			add(new Label => [
				text = castedModel.valueString
				setSize(75, 25)
			])
		]
	}
	
	def createShape() {
		new Ellipse
	}
	
	def colorFor(VariableModel model) {
		val configuration = DynamicDiagramConfiguration.instance
		if (model.valueString == "null")
			DiagramColors.OBJECTS_VALUE_NULL
		else if (model.isUserDefined)
			if (configuration.colorBlindEnabled) DiagramColors.OBJECTS_CUSTOM_BACKGROUND_COLORBLIND else DiagramColors.OBJECTS_CUSTOM_BACKGROUND
		else
			if (configuration.colorBlindEnabled) DiagramColors.OBJECTS_WRE_BACKGROUND_COLORBLIND else DiagramColors.OBJECTS_WRE_BACKGROUND
	}

	def lineWidthFor(VariableModel model) {
		if (model.isUserDefined && DynamicDiagramConfiguration.instance.colorBlindEnabled) 2 else 1
	}

	def getCastedModel() { model as VariableModel }

	def getConnectionAnchor() {
		if (anchor === null) anchor = createConnectionAnchor()
		anchor
	}
	
	def createConnectionAnchor() {
		new EllipseAnchor(figure)
	}
	
	override List<Connection> getModelSourceConnections() { castedModel.sourceConnections }
	override List<Connection> getModelTargetConnections() { castedModel.targetConnections }

	// anchors
		
	override getSourceConnectionAnchor(ConnectionEditPart connection) { connectionAnchor }
	override getSourceConnectionAnchor(Request request) { connectionAnchor }
	override getTargetConnectionAnchor(ConnectionEditPart connection) { connectionAnchor }
	override getTargetConnectionAnchor(Request request) { connectionAnchor }

	override propertyChange(PropertyChangeEvent evt) {
		val prop = evt.propertyName
		if (Shape.SOURCE_CONNECTIONS_PROP == prop)	refreshSourceConnections
		if (Shape.TARGET_CONNECTIONS_PROP == prop)	refreshTargetConnections
		if (Shape.SIZE_PROP == prop) {
			refreshVisuals
			DynamicDiagramConfiguration.instance.saveSize(castedModel)
		}
		if (Shape.LOCATION_PROP == prop) {
			refreshVisuals
			DynamicDiagramConfiguration.instance.saveLocation(castedModel)
		}
	}

	override refreshVisuals() {
		(parent as GraphicalEditPart).setLayoutConstraint(this, figure, castedModel.bounds)
	}
	
	def getBounds(Shape it) { new Rectangle(location, size) }

	def isConstantReference() {
		castedModel.variable.isConstant
	}
}