package org.uqbar.project.wollok.ui.diagrams.classes.model;

import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * A rectangular shape.
 * 
 * @author jfernandes
 */
class ClassModel extends Shape {
	@Property WClass clazz
	
	new(WClass wClass) {
		clazz = wClass
	}

	override toString() {
		"ClassModel<" + clazz.name + ">"		
	}
}
