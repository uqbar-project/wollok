package org.uqbar.project.wollok.ui.diagrams.classes.parts

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.List
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.gef.ConnectionEditPart
import org.eclipse.gef.EditPart
import org.eclipse.gef.EditPolicy
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.NodeEditPart
import org.eclipse.gef.Request
import org.eclipse.gef.editpolicies.ComponentEditPolicy
import org.eclipse.gef.editpolicies.FlowLayoutEditPolicy
import org.eclipse.gef.requests.CreateRequest
import org.uqbar.project.wollok.ui.diagrams.classes.anchors.DefaultWollokAnchor
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.wollokDsl.WMember
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

/**
 * Abstract base class for edit parts for (named) objects and classes
 * which share some common behavior.
 * 
 * @author jfernandes
 */
abstract class AbstractMethodContainerEditPart extends AbstractLanguageElementEditPart implements PropertyChangeListener, NodeEditPart {
	protected ConnectionAnchor anchor

	def Shape getCastedModel()

	override activate() {
		if (!active) {
			super.activate
			castedModel.size = max(figure.preferredSize, (100 -> 0))
			castedModel.addPropertyChangeListener(this)
		}
	}
	
	def static max(Dimension d, Pair<Integer, Integer> other) {
		new Dimension(Math.max(d.width, other.key), Math.max(d.height, other.value))
	}
	
	override deactivate() {
		if (active) {
			super.deactivate
			castedModel.removePropertyChangeListener(this)
		}
	}
	
	def getConnectionAnchor() {
		if (anchor == null)
			anchor = createConnectionAnchor
		anchor
	}
	
	def ConnectionAnchor createConnectionAnchor() {
		new DefaultWollokAnchor(figure)
	}
	
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
	
	override getModelSourceConnections() { castedModel.sourceConnections }
	override getModelTargetConnections() { castedModel.targetConnections }
	override getSourceConnectionAnchor(ConnectionEditPart connection) { connectionAnchor }
	override getSourceConnectionAnchor(Request request) { connectionAnchor }
	override getTargetConnectionAnchor(ConnectionEditPart connection) { connectionAnchor }
	override getTargetConnectionAnchor(Request request) { connectionAnchor }

	override propertyChange(PropertyChangeEvent evt) {
		val prop = evt.propertyName
		if (Shape.SIZE_PROP == prop || Shape.LOCATION_PROP == prop) {
			refreshVisuals
			if (Shape.SIZE_PROP == prop) {
				castedModel.configuration.saveSize(castedModel)
			}
			if (Shape.LOCATION_PROP == prop) {
				castedModel.configuration.saveLocation(castedModel)
			}
		}
		else if (Shape.SOURCE_CONNECTIONS_PROP == prop)
			refreshSourceConnections
		else if (Shape.TARGET_CONNECTIONS_PROP == prop)
			refreshTargetConnections
	}

	override refreshVisuals() {
		(parent as GraphicalEditPart).setLayoutConstraint(this, figure, castedModel.bounds)
	}

	override getModelChildren() {
		// avoiding getters & setters
		val variables = doGetModelChildren
			.filter [ member | member.isVariable ]
			.map [ member | (member as WVariableDeclaration).variable.name ]
			.toList
		
		doGetModelChildren.filter [ member | member.isNotAccessor(variables) ].toList
	}
	
	def List doGetModelChildren()

	def dispatch boolean isNotAccessor(WMember member, List<String> variables) {
		true
	}
	
	def dispatch boolean isNotAccessor(WMethodDeclaration method, List<String> variables) {
		!variables.contains(method.name)  		
	}

	def dispatch Boolean isVariable(WMember member) {
		false
	}

	def dispatch Boolean isVariable(WVariableDeclaration member) {
		true
	}
	
}