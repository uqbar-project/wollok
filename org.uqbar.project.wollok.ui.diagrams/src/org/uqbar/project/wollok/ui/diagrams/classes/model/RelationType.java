package org.uqbar.project.wollok.ui.diagrams.classes.model;

import org.eclipse.draw2d.Graphics;
import org.uqbar.project.wollok.ui.diagrams.Messages;
import org.uqbar.project.wollok.ui.diagrams.classes.parts.AssociationConnectionEditPart;
import org.uqbar.project.wollok.ui.diagrams.classes.parts.DependencyConnectionEditPart;
import org.uqbar.project.wollok.ui.diagrams.classes.parts.InheritanceConnectionEditPart;
import org.uqbar.project.wollok.ui.diagrams.editparts.ConnectionEditPart;

public enum RelationType {

	INHERITANCE, ASSOCIATION, DEPENDENCY;

	public void validateRelationBetween(Shape source, Shape target) {
		if (source == target && this == RelationType.INHERITANCE) {
			throw new IllegalArgumentException(Messages.StaticDiagram_InheritanceCannotBeSelfRelated);
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
}
