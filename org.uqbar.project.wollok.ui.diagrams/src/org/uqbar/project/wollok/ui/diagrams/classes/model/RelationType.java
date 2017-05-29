package org.uqbar.project.wollok.ui.diagrams.classes.model;

import org.uqbar.project.wollok.ui.diagrams.Messages;

public enum RelationType {

	INHERITANCE, ASSOCIATION, DEPENDENCY;

	public void validateRelationBetween(Shape source, Shape target) {
		if (source == target && this == RelationType.INHERITANCE) {
			throw new IllegalArgumentException(Messages.StaticDiagram_InheritanceCannotBeSelfRelated);
		}
	}
}
