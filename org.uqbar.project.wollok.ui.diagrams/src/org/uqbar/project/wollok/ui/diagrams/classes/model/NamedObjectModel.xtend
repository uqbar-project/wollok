package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.eclipse.draw2d.geometry.Point

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
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
		obj.hasRealParent // By now it is ok, but we should consider also associations
	}
	
	def locate() {
		location = new Point(objectsCount * width, VERTICAL_POSITION)
	}
	
	/**
	 * TODO: Define a strategy based on custom size (with/without methods)  
	 */
	def width() {
		110
	}

}