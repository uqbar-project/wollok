package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.Ellipse
import org.eclipse.draw2d.EllipseAnchor
import org.eclipse.draw2d.Figure
import org.eclipse.draw2d.Label
import org.eclipse.draw2d.RectangleFigure
import org.eclipse.draw2d.StackLayout
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.ConnectionEditPart
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.NodeEditPart
import org.eclipse.gef.Request
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.eclipse.draw2d.ChopboxAnchor
import org.uqbar.project.wollok.ui.diagrams.classes.view.StaticDiagramColors
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration
import java.util.List
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection

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
		
			val c = colorFor(castedModel)
			this.ellipse = createShape() => [
				backgroundColor = c
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
		if (castedModel.isCollection)
			new RectangleFigure
		else
			new Ellipse
	}
	
	def colorFor(VariableModel model) {
		val v = model.valueString
		if (v == "null")
			StaticDiagramColors.OBJECTS_VALUE_NULL
		else if (model.isNumeric)
			StaticDiagramColors.OBJECTS_VALUE_NUMERIC_BACKGROUND
		else if (model.isCollection)
			StaticDiagramColors.OBJECTS_VALUE_COLLECTION_BACKGROUND
		else if (model.isString)
			StaticDiagramColors.OBJECTS_VALUE_STRING_BACKGROUND
		else if (model.isNative)
			StaticDiagramColors.OBJECTS_VALUE_NATIVE_BACKGROUND
		else if (model.isUserDefined)
			StaticDiagramColors.OBJECT_USER_DEFINED_BACKGROUND
		else
			StaticDiagramColors.CLASS_BACKGROUND
	}
	
	def getCastedModel() { model as VariableModel }

	def getConnectionAnchor() {
		if (anchor === null) anchor = createConnectionAnchor()
		anchor
	}
	
	def createConnectionAnchor() {
		if (castedModel.isCollection)
			new ChopboxAnchor(figure)
		else
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
//	def getBounds() { new Rectangle((Math.random * 200).intValue, (Math.random * 200).intValue, 75, 75) }

}