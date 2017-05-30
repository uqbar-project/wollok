package org.uqbar.project.wollok.ui.diagrams.classes.model

import java.util.List
import org.eclipse.draw2d.geometry.Point
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
	public static List<NamedObjectModel> objects
	public static int VERTICAL_POSITION = 15
	
	static def void init() {
		objects = newArrayList
	}
	
	new(WNamedObject obj) {
		super(obj)
		objects.add(this)
	}

	override toString() {
		"ObjectModel<" + this.name + ">"		
	}
	
	override shouldShowConnectorTo(WClass clazz) {
		component.hasRealParent
	}
	
	def locate() {
		location = configuration.getLocation(this) ?: new Point(XPosition, INITIAL_MARGIN)
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
	
	def static int maxHeight() {
		objects.fold(0, [ max, object | Math.max(max, object.size.height + VERTICAL_POSITION) ]) 
	}

}
