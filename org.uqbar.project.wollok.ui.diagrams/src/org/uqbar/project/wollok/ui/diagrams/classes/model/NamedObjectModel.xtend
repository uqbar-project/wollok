package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */
class NamedObjectModel extends Shape {
	@Accessors WNamedObject obj
	
	new(WNamedObject obj) {
		this.obj = obj
	}

	override toString() {
		"ObjectModel<" + obj.name + ">"		
	}
}