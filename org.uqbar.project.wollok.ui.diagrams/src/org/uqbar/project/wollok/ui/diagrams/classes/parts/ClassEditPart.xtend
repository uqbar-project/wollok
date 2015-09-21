package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import org.eclipse.draw2d.ChopboxAnchor
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.ConnectionEditPart
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.NodeEditPart
import org.eclipse.gef.Request
import org.eclipse.gef.editparts.AbstractGraphicalEditPart
import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.classes.view.WAttributteFigure
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure
import org.uqbar.project.wollok.ui.diagrams.classes.view.WMethodFigure
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * @author jfernandes
 */
class ClassEditPart extends AbstractGraphicalEditPart implements PropertyChangeListener, NodeEditPart {
	ConnectionAnchor anchor

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
		new WClassFigure(castedModel.clazz.name) => [ f |
			f.abstract = castedModel.clazz.abstract
			castedModel.clazz.members.forEach[m| f.add(createMemberFigure(m)) ]
		]
	}
	
	def dispatch createMemberFigure(WMethodDeclaration member) { new WMethodFigure(member) }
	def dispatch createMemberFigure(WVariableDeclaration member) { new WAttributteFigure(member) }

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
	
	def getBounds(Shape it) { new Rectangle(location, size) }
}