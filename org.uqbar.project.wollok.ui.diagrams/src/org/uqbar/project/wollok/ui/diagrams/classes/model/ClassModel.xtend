package org.uqbar.project.wollok.ui.diagrams.classes.model;

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * A rectangular shape.
 * 
 * @author jfernandes
 */
@Accessors
class ClassModel extends Shape {
	WClass clazz
	
	new(WClass wClass) {
		clazz = wClass
	}

	override toString() {
		"ClassModel<" + clazz.name + ">"		
	}
	
}
