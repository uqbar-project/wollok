package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.List
import java.util.Map
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * A rectangular shape.
 * 
 * @author jfernandes
 */
@Accessors
class ClassModel extends Shape {
	static List<WClass> classes = newArrayList
	static Map<Integer, Integer> levelWidth = newHashMap
	WClass clazz
	
	static def void init(List<WClass> _classes) {
		org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel.levelWidth = newHashMap
		classes = _classes
	}
	
	new(WClass wClass) {
		clazz = wClass
	}

	override toString() {
		"ClassModel<" + clazz.name + ">"		
	}
	
	def locate(int level) {
		// TODO: If autorefresh set to true, define padding based on how many clazzes are
		var int calculatedWidth = levelWidth.get(level) ?: 0
		val subclassesCount = classes.clone.filter [ it.parent != null && it.parent == this.clazz ].size
		val adjustedWidth = calculatedWidth + width + adjustedWidth(subclassesCount)
		location = new Point(adjustedWidth, level * height)
		levelWidth.put(level, calculatedWidth + nextWidth(subclassesCount))
	}
	
	def int adjustedWidth(int subclassesCount) { 
		if (subclassesCount == 0) {
			return 0
		}
		new Double((subclassesCount * width * 0.5) - (width * 0.5)).intValue	
	}
	
	def int nextWidth(int subclassesCount) { 
		if (subclassesCount == 0) {
			return width
		}
		subclassesCount * width	
	}
		
	/**
	 * TODO: Define a strategy based on size of control  
	 */
	def width() {
		120
	}

	def height() {
		130
	}
	
}
