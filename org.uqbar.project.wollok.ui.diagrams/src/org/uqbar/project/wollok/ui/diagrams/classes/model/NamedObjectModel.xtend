package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.uqbar.project.wollok.wollokDsl.WNamedObject

/**
 * @author jfernandes
 */
class NamedObjectModel extends Shape {
	@Property WNamedObject obj
	
	new(WNamedObject obj) {
		this.obj = obj
	}

	override toString() {
		"ObjectModel<" + obj.name + ">"		
	}
}