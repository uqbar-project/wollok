package org.uqbar.project.wollok.ui.diagrams.classes.model;

import org.eclipse.draw2d.Graphics;
import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.ui.diagrams.Messages;
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart;
import org.uqbar.project.wollok.ui.diagrams.classes.parts.DependencyConnectionEditPart;
import org.uqbar.project.wollok.ui.diagrams.classes.parts.InheritanceConnectionEditPart;
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart;

public enum RelationType {

	INHERITANCE, ASSOCIATION, DEPENDENCY;

	public void validateRelationBetween(Shape source, Shape target) {
		if (source == target && this != RelationType.ASSOCIATION) {
			throw new IllegalArgumentException(NLS.bind(Messages.StaticDiagram_RelationCannotBeSelfRelated, this.toString()));
		}
	}

	public int getLineStyle() {
		if (this == RelationType.DEPENDENCY)
			return Graphics.LINE_DASH;
		else
			return Graphics.LINE_SOLID;
	}

	public ConnectionEditPart getConnectionEditPart() {
		if (this == RelationType.INHERITANCE)
			return new InheritanceConnectionEditPart();
			
		if (this == RelationType.ASSOCIATION)
			return new AssociationConnectionEditPart();
			
		if (this == RelationType.DEPENDENCY)
			return new DependencyConnectionEditPart();
		
		throw new IllegalArgumentException(Messages.StaticDiagram_Invalid_Relation_Type);
	}
	
	@Override
	public String toString() {
		if (this == RelationType.INHERITANCE)
			return Messages.RelationType_InheritanceDescription;
			
		if (this == RelationType.ASSOCIATION)
			return Messages.RelationType_AssociationDescription;
			
		if (this == RelationType.DEPENDENCY)
			return Messages.RelationType_DependencyDescription;
		
		return "";
	}
}
