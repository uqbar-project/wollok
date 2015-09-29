package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import org.eclipse.draw2d.ChopboxAnchor
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.ConnectionEditPart
import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.NodeEditPart
import org.eclipse.gef.Request
import org.eclipse.gef.RequestConstants
import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.eclipse.gef.editpolicies.FlowLayoutEditPolicy
import org.eclipse.gef.requests.CreateRequest
import org.eclipse.xtext.EcoreUtil2
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * @author jfernandes
 */
class ClassEditPart extends AbstractLanguageElementEditPart implements PropertyChangeListener, NodeEditPart {
	ConnectionAnchor anchor

	override activate() {
		if (!active) {
			super.activate
			castedModel.size = max(figure.preferredSize, (100 -> 0))
			castedModel.addPropertyChangeListener(this)
		}
	}
	
	def max(Dimension d, Pair<Integer, Integer> other) {
		new Dimension(Math.max(d.width, other.key), Math.max(d.height, other.value))
	}
	
	override deactivate() {
		if (active) {
			super.deactivate
			castedModel.removePropertyChangeListener(this)
		}
	}
	
	override getModelChildren() { castedModel.clazz.members }

	override createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new ComponentEditPolicy {})
		installEditPolicy(EditPolicy.CONTAINER_ROLE, new ClassContainerEditPolicy)
		// to be able to select child parts
		installEditPolicy(EditPolicy.LAYOUT_ROLE, new FlowLayoutEditPolicy {
			override protected createAddCommand(EditPart arg0, EditPart arg1) {}
			override protected createMoveChildCommand(EditPart arg0, EditPart arg1) {}
			override protected getCreateCommand(CreateRequest arg0) {}
		})
	}
	
	override createFigure() {
		new WClassFigure(castedModel.clazz.name) => [ f |
			f.abstract = castedModel.clazz.abstract
		]		
	}
	
	override getLanguageElement() { castedModel.clazz }
	
	def getCastedModel() { model as ClassModel }

	def getConnectionAnchor() {
		if (anchor == null)
			anchor = new ChopboxAnchor(figure)
		anchor
	}
	
	override getModelSourceConnections() {
		castedModel.sourceConnections
	}

	override getModelTargetConnections() {
		castedModel.targetConnections
	}

	override getSourceConnectionAnchor(ConnectionEditPart connection) {
		connectionAnchor
	}

	override getSourceConnectionAnchor(Request request) {
		connectionAnchor
	}

	override getTargetConnectionAnchor(ConnectionEditPart connection) {
		connectionAnchor
	}

	override getTargetConnectionAnchor(Request request) {
		connectionAnchor
	}

	override propertyChange(PropertyChangeEvent evt) {
		val prop = evt.propertyName
		if (Shape.SIZE_PROP == prop || Shape.LOCATION_PROP == prop)
			refreshVisuals
		else if (Shape.SOURCE_CONNECTIONS_PROP == prop)
			refreshSourceConnections
		else if (Shape.TARGET_CONNECTIONS_PROP == prop)
			refreshTargetConnections
	}

	override refreshVisuals() {
		(parent as GraphicalEditPart).setLayoutConstraint(this, figure, castedModel.bounds)
	}
	
	def getBounds(Shape it) {
		new Rectangle(location, size)
	}
}