package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Association implements Cloneable, Serializable {
	String source
	String target
	
	new(String _source, String _target) {
		this.source = _source
		this.target = _target
	}
	
	override toString() {
		source + " -> " + target
	}
	
}
