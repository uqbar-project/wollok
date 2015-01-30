package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import org.eclipse.draw2d.PolygonDecoration
import org.eclipse.draw2d.PolylineConnection
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.editparts.AbstractConnectionEditPart
import org.eclipse.gef.editpolicies.ConnectionEndpointEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection

/**
 * @author jfernandes
 */
class ConnectionEditPart extends AbstractConnectionEditPart implements PropertyChangeListener {

	override activate() {
		if (!active) {
			super.activate;
			castedModel.addPropertyChangeListener(this)
		}
	}

	override createEditPolicies() {
		installEditPolicy(EditPolicy.CONNECTION_ENDPOINTS_ROLE, new ConnectionEndpointEditPolicy)
	}

	override createFigure() {
		super.createFigure as PolylineConnection => [
			targetDecoration = new PolygonDecoration
			lineStyle = castedModel.lineStyle
		]
	}

	override deactivate() {
		if (active) {
			super.deactivate;
			castedModel.removePropertyChangeListener(this)
		}
	}

	def getCastedModel() {
		model as Connection
	}

	override propertyChange(PropertyChangeEvent event) {
		val property = event.propertyName
		if (Connection.LINESTYLE_PROP == property)
			(figure as PolylineConnection).lineStyle = castedModel.lineStyle
	}

}