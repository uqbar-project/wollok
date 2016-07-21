package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject

/**
 * @author jfernandes
 */
class NamedObjectModel extends Shape {
	@Accessors WNamedObject obj
	public static int objectsCount = 0
	public static int VERTICAL_POSITION = 10
	
	static def void init() {
		objectsCount = 0
	}
	
	new(WNamedObject obj) {
		this.obj = obj
		objectsCount++
	}

	override toString() {
		"ObjectModel<" + obj.name + ">"		
	}
	
	override shouldShowConnectorTo(WClass clazz) {
		!clazz.name.equalsIgnoreCase("Object")
	}
	
	def locate() {
		location = new Point(objectsCount * width, VERTICAL_POSITION)
	}
	
	/**
	 * TODO: Define a strategy based on how many  
	 */
	def width() {
		110
	}

}