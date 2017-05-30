package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType

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
