package org.uqbar.project.wollok.ui.diagrams.editparts

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.net.URL
import org.eclipse.draw2d.ConnectionLocator
import org.eclipse.draw2d.Label
import org.eclipse.draw2d.MidpointLocator
import org.eclipse.draw2d.PolylineConnection
import org.eclipse.draw2d.RotatableDecoration
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.editparts.AbstractConnectionEditPart
import org.eclipse.gef.editpolicies.ConnectionEndpointEditPolicy
import org.eclipse.jface.resource.ImageDescriptor
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection

import static extension org.uqbar.project.wollok.ui.utils.WollokDynamicDiagramUtils.*

/**
 * @author jfernandes
 */
abstract class ConnectionEditPart extends AbstractConnectionEditPart implements PropertyChangeListener {

	override activate() {
		if (!active) {
			super.activate
			castedModel.addPropertyChangeListener(this)
		}
	}

	override createEditPolicies() {
		installEditPolicy(EditPolicy.CONNECTION_ENDPOINTS_ROLE, new ConnectionEndpointEditPolicy)
	}
	
	override createFigure() {
		super.createFigure as PolylineConnection => [
			targetDecoration = createEdgeDecoration()
			lineStyle = castedModel.lineStyle
			lineWidth = castedModel.lineWidth
			if (castedModel.name !== null) {
				var Label label
				if (castedModel.source !== null && castedModel.source.isConstant(castedModel.name)) {
					val image = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.jdt.debug.ui/icons/full/elcl16/deadlock_view.gif")).createImage
					label = new Label(castedModel.nameForPrinting, image)
				} else {
					label = new Label(castedModel.nameForPrinting)
				}
				add(label => [ 
					opaque = true
				], createConnectionLocator)
			}
		]
	}
		
	def ConnectionLocator createConnectionLocator(PolylineConnection connection) {
		new MidpointLocator(connection, 0)
	}
	
	def RotatableDecoration createEdgeDecoration()

	override deactivate() {
		if (active) {
			super.deactivate
			castedModel.removePropertyChangeListener(this)
		}
	}

	def getCastedModel() {
		model as Connection
	}

	override propertyChange(PropertyChangeEvent event) {
		val property = event.propertyName
		if (Connection.LINESTYLE_PROP == property)
			(figure as PolylineConnection) => [
				lineStyle = castedModel.lineStyle
			]
	}
	
}