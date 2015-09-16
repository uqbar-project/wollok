package org.uqbar.project.wollok.ui.diagrams.objects.parts

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
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
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.view.ClassDiagramColors

/**
 * 
 * @author jfernandes
 */
class ValueEditPart extends AbstractGraphicalEditPart implements PropertyChangeListener, NodeEditPart {
	ConnectionAnchor anchor
	Ellipse ellipse
	
	override activate() {
		if (!active) {
			super.activate;
			castedModel.addPropertyChangeListener(this)
		}
	}
	
	override deactivate() {
		if (active) {
			super.deactivate;
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
			println(" >>>>>>>>> model color for " + castedModel.valueString + " is " + c)
			
			add(this.ellipse = new Ellipse => [
				backgroundColor = c
				opaque = true
			])
			add(new Label => [
				text = castedModel.valueString
				setSize(75, 25)
			])
		]
	}
	
	def colorFor(VariableModel model) {
		val v = model.valueString
		if (v == "null")
			ClassDiagramColors.OBJECTS_VALUE_NULL
		else if (v.isNumeric)
			ClassDiagramColors.OBJECTS_VALUE_NUMERIC_BACKGROUND
		else 
			ClassDiagramColors.CLASS_BACKGROUND
	}
	
	def dispatch isNumeric(Void v) { false }
	def dispatch isNumeric(String str) {
		return str.matches("^-?\\d+(\\.\\d+)?$");
	} 
	
	def getCastedModel() { model as VariableModel }

	def getConnectionAnchor() {
		if (anchor == null) anchor = new EllipseAnchor(figure)
		anchor
	}
	
	override getModelSourceConnections() { castedModel.sourceConnections }
	override getModelTargetConnections() { castedModel.targetConnections }

	// anchors
		
	override getSourceConnectionAnchor(ConnectionEditPart connection) { connectionAnchor }
	override getSourceConnectionAnchor(Request request) { connectionAnchor }
	override getTargetConnectionAnchor(ConnectionEditPart connection) { connectionAnchor }
	override getTargetConnectionAnchor(Request request) { connectionAnchor }

	override propertyChange(PropertyChangeEvent evt) {
		val prop = evt.propertyName
		if (Shape.SIZE_PROP == prop || Shape.LOCATION_PROP == prop) refreshVisuals
		else if (Shape.SOURCE_CONNECTIONS_PROP == prop)	refreshSourceConnections
		else if (Shape.TARGET_CONNECTIONS_PROP == prop)	refreshTargetConnections
	}

	override refreshVisuals() {
		(parent as GraphicalEditPart).setLayoutConstraint(this, figure, castedModel.bounds)
	}
	
	def getBounds(Shape it) { new Rectangle(location, size) }
//	def getBounds() { new Rectangle((Math.random * 200).intValue, (Math.random * 200).intValue, 75, 75) }
	
}