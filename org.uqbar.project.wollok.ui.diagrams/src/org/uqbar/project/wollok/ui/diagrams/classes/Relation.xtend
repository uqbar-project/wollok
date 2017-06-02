package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType

/**
 * 
 * Relation models a relationship between two nodes (wko, class or mixin)
 * Relation type can one of the followings
 * - association
 * - dependency
 * - inheritance
 * 
 * @author dodain
 * 
 */
@Accessors
class Relation implements Cloneable, Serializable {
	String source
	String target
	RelationType relationType
	
	new(String _source, String _target, RelationType _relationType) {
		this.source = _source
		this.target = _target
		this.relationType = _relationType
	}
	
	override toString() {
		source + connector + target
	}
	
	def connector() {
		if (relationType == RelationType.ASSOCIATION) " -> " else " .> "
	}
	
}
