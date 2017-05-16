package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass

import static extension java.lang.Integer.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * A rectangular shape.
 * 
 * @author jfernandes
 */
@Accessors
class ClassModel extends Shape {
	static List<WClass> classes = newArrayList
	static Map<String, Integer> heights
	static Map<Integer, Integer> levelWidth = newHashMap
	val static LETTER_WIDTH = 9
	val static FILE_HEIGHT = 18
	val static CLASS_WIDTH = 45
	val static CLASS_HEIGHT = 55
	val static WIDTH_SEPARATION_BETWEEN_CLASSES = 30
	val static HEIGHT_SEPARATION_BETWEEN_CLASSES = 20
	val static INITIAL_MARGIN = 5
	
	WClass clazz
	boolean imported = false
	
	
	static def void init(List<WClass> _classes) {
		levelWidth = newHashMap
		classes = _classes
		heights = new HashMap<String, Integer>
		classes.forEach [ heights.put(it.name, 0) ]
	}
	
	new(WClass wClass) {
		clazz = wClass
		defineSize
	}
	
	def void defineSize() {
		size = new Dimension(clazz.shapeWidth, clazz.shapeHeight)
	}
	
	def int shapeWidth(WClass wClass) {
		CLASS_WIDTH + (wClass.allWidths.reduce [ a, b | a.max(b) ] * LETTER_WIDTH)
	}
	
	def allWidths(WClass wClass) {
		// TODO: Considerar solo si se muestran las variables
		val result = wClass.variables.map [ it.name?.length ].toList
		//
		result.addAll(wClass.methods.map [ it.name?.length ])
		result.add(wClass.name.length)
		result
	}
	
	def int shapeHeight(WClass wClass) {
		// TODO: Considerar solo si se muestran las variables
		(wClass.variables.size + wClass.methods.size) * FILE_HEIGHT + CLASS_HEIGHT
	}

	override toString() {
		"ClassModel<" + clazz.name + ">"		
	}
	
	def locate(int level) {
		val subclasses = classes.clone.filter [ it.parent !== null && it.parent == this.clazz ].toList
		val calculatedWidthOfSubclasses = subclasses.calculatedWidth
		var initialWidth = levelWidth.get(level) ?: INITIAL_MARGIN
		val addedWidthOfShape = this.clazz.shapeWidth + WIDTH_SEPARATION_BETWEEN_CLASSES
		val xPosition = initialWidth + (calculatedWidthOfSubclasses / 2).intValue
		location = new Point(xPosition, getCalculatedHeight(level, subclasses))
		subclasses.adjustHeightForSubclasses()
		levelWidth.put(level, initialWidth + addedWidthOfShape + calculatedWidthOfSubclasses)
	}
	
	def getCalculatedHeight(int level, List<WClass> subclasses) {
		val currentHeight = heights.get(this.clazz.name) ?: 0
		adjustedHeight + (level * HEIGHT_SEPARATION_BETWEEN_CLASSES) + currentHeight
	}
	
	def void adjustHeightForSubclasses(List<WClass> subclasses) {
		var currentHeightForSubclasses = 0
		if (!subclasses.empty) {
			currentHeightForSubclasses = heights.get(subclasses.head.name) ?: 0
		}
		val currentClassHeight = this.clazz.shapeHeight + heights.get(this.clazz.name)
		val newHeightForSubclasses = Math.max(currentClassHeight, currentHeightForSubclasses)
		subclasses.forEach [ 
			heights.put(it.name, newHeightForSubclasses)
		]
	}
	
	def getCalculatedWidth(List<WClass> subclasses) {
		subclasses.indexOf(this.clazz)
		var allSubclassesWidth = 0 // I have to do this because a strange NPE
		if (!subclasses.empty) {
			allSubclassesWidth = subclasses.map [ shapeWidth ].reduce [ a, b | a + b ]
		}
		val margin = subclasses.size * WIDTH_SEPARATION_BETWEEN_CLASSES
		allSubclassesWidth + margin
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
	
	def adjustedHeight() {
		if (NamedObjectModel.objectsCount + MixinModel.mixinsCount > 0) {
			0
		} else {
			150
		}
	}
	
	def getName() {
		clazz.name ?: ""
	}
	
}
