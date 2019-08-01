package org.uqbar.project.wollok.ui.diagrams.classes.parts

import java.beans.PropertyChangeEvent
import java.beans.PropertyChangeListener
import java.util.List
import java.util.Map
import org.eclipse.draw2d.ConnectionAnchor
import org.eclipse.draw2d.IFigure
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
import org.uqbar.project.wollok.ui.diagrams.classes.anchors.WollokAssociationAnchor
import org.uqbar.project.wollok.ui.diagrams.classes.editPolicies.ClassContainerEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.editPolicies.CreateAssociationEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.editPolicies.HideComponentEditPolicy
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.wollokDsl.WMember
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.ui.diagrams.classes.editPolicies.ShowHiddenPartsElementEditPolicy

/**
 * Abstract base class for edit parts for (named) objects and classes
 * which share some common behavior.
 * 
 * @author jfernandes
 */
abstract class AbstractMethodContainerEditPart extends AbstractLanguageElementEditPart implements PropertyChangeListener, NodeEditPart {
	protected Map<ConnectionEditPart, ConnectionAnchor> connectionAnchors = newHashMap
	protected Map<Request, ConnectionAnchor> requestAnchors = newHashMap

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
	
	def ConnectionAnchor createConnectionAnchorFor(ConnectionEditPart connection) {
		new DefaultWollokAnchor(figure)
	}
	
	/** http://help.eclipse.org/kepler/index.jsp?topic=%2Forg.eclipse.gef.doc.isv%2Fguide%2Fguide.html */
	override createEditPolicies() {
		installEditPolicy(EditPolicy.COMPONENT_ROLE, new ComponentEditPolicy {})
		installEditPolicy(EditPolicy.CONTAINER_ROLE, new ClassContainerEditPolicy)
		// to be able to select child parts
		installEditPolicy(EditPolicy.LAYOUT_ROLE, new FlowLayoutEditPolicy {
			override protected createAddCommand(EditPart arg0, EditPart arg1) {	}
			override protected createMoveChildCommand(EditPart arg0, EditPart arg1) {}
			override protected getCreateCommand(CreateRequest arg0) {}
		})
		installEditPolicy(EditPolicy.SELECTION_FEEDBACK_ROLE, new HideComponentEditPolicy)
		installEditPolicy(EditPolicy.SELECTION_FEEDBACK_ROLE, new ShowHiddenPartsElementEditPolicy)
		installEditPolicy(EditPolicy.GRAPHICAL_NODE_ROLE, new CreateAssociationEditPolicy)
	}
	
	override List<Connection> getModelSourceConnections() { castedModel.sourceConnections }
	override List<Connection> getModelTargetConnections() { castedModel.targetConnections }
	
	override getSourceConnectionAnchor(ConnectionEditPart connection) {
		connection.mappedConnectionAnchor
	}

	override getTargetConnectionAnchor(ConnectionEditPart connection) { 
		connection.mappedConnectionAnchor
	}

	// NO LO USA EL ROOT VARIABLE	
	def ConnectionAnchor mappedConnectionAnchor(ConnectionEditPart connection) {
		val anchor = connectionAnchors.get(connection)
		if (anchor !== null) return anchor
		val newAnchor = connection.connectionAnchor
		connectionAnchors.put(connection, newAnchor)
		newAnchor
	}
	
	def dispatch ConnectionAnchor connectionAnchor(ConnectionEditPart connection) { 
		new DefaultWollokAnchor(figure)
	}
	
	def dispatch ConnectionAnchor connectionAnchor(AssociationConnectionEditPart part) {
		figure.defaultAssociationAnchorFor(part.castedModel)
	}
	
	override getSourceConnectionAnchor(Request request) {
		new DefaultWollokAnchor(figure)
	}

	override getTargetConnectionAnchor(Request request) {
		new DefaultWollokAnchor(figure)
	}

	def ConnectionAnchor defaultAssociationAnchorFor(IFigure figure, Connection connection) {
		new WollokAssociationAnchor(figure, connection)
	}
	
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

	override List<WMember> getModelChildren() {
		// avoiding getters & setters
		val variables = doGetModelChildren
			.filter [ member | member.isVariable ]
			.map [ member | (member as WVariableDeclaration).variable.name ]
			.toList
		
		doGetModelChildren.filter [ member | member.isNotAccessor(variables) ].toList
	}
	
	def doGetModelChildren() {
		(castedModel as AbstractModel).members
	}

	def dispatch boolean isNotAccessor(WMember named, List<String> variables) {
		true
	}
	
	def dispatch boolean isNotAccessor(WMethodDeclaration method, List<String> variables) {
		!variables.contains(method.name)  		
	}

}