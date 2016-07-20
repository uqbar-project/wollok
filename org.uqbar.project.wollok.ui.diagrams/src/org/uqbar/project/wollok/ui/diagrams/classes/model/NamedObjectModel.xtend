package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject

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
	
	override shouldShowConnectorTo(WClass clazz) {
		!clazz.name.equalsIgnoreCase("Object")
	}
	
}