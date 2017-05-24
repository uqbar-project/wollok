package org.uqbar.project.wollok.ui.diagrams.classes.model

import java.util.List
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * Rectangular Figure modeling a wko
 * 
 * @author jfernandes
 * @author dodain
 */
class NamedObjectModel extends AbstractModel {
	@Accessors WNamedObject obj
	public static List<NamedObjectModel> objects

	public static int VERTICAL_POSITION = 10
	public static int OBJECT_LEVEL_HEIGHT = 150
	
	static def void init() {
		objects = newArrayList
	}
	
	new(WNamedObject obj) {
		this.obj = obj
		obj.defineSize
		objects.add(this)
	}

	override toString() {
		"ObjectModel<" + obj.name + ">"		
	}
	
	override shouldShowConnectorTo(WClass clazz) {
		obj.hasRealParent // By now it is ok, but we should consider also associations
	}
	
	def locate() {
		location = configuration.getLocation(this) ?: new Point(XPosition, VERTICAL_POSITION)
	}

	def int getXPosition() {
		val allWidths = objects
			.clone
			.filter [ !it.equals(this) ]
			.fold(0, [acum, object |
				acum + object.size.width
			]) 
		INITIAL_MARGIN + (objects.size * WIDTH_SEPARATION_BETWEEN_ELEMENTS) + allWidths
	}
	
	def widthForPosition() {
		130
	}
	
	def static int maxHeight() {
		objects.fold(OBJECT_LEVEL_HEIGHT, [ max, object | Math.max(max, object.size.height) ])
	}

	override getLabel() {
		obj.name
	}
	
}
