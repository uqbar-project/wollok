package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.List
import java.util.Map
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WClass

import static extension java.lang.Integer.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.WollokConstants

/**
 * A rectangular shape.
 * 
 * @author jfernandes
 */
@Accessors
class ClassModel extends Shape {
	var int objectsAndMixins = 0
	static List<WClass> classes = newArrayList
	static Map<Integer, Integer> levelHeight
	static Map<Integer, Integer> levelWidth
	static Map<String, Integer> initialWidthForClass
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
		levelHeight = newHashMap
		levelWidth = newHashMap
		initialWidthForClass = newHashMap
		classes = _classes
	}
	
	new(WClass wClass) {
		clazz = wClass
		defineSize
		objectsAndMixins = NamedObjectModel.objectsCount + MixinModel.mixinsCount
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
		var initialWidth = Math.max(levelWidth.get(level) ?: INITIAL_MARGIN, this.clazz.initialWidth)
		val addedWidthOfShape = this.clazz.shapeWidth + WIDTH_SEPARATION_BETWEEN_CLASSES
		val xPosition = initialWidth + (calculatedWidthOfSubclasses / 2).intValue
		initialWidthForClass.put(this.clazz.name, initialWidth)
		location = new Point(xPosition, level.calculatedHeight)
		level.adjustHeight
		levelWidth.put(level, initialWidth + addedWidthOfShape + calculatedWidthOfSubclasses)
	}
	
	def int getInitialWidth(WClass wClass) {
		if (wClass.parent === null || wClass.parent.name.equals(WollokConstants.ROOT_CLASS)) return 0;
		initialWidthForClass.get(wClass.parent.name) ?: 0
	}
	
	def getCalculatedHeight(int level) {
		val Integer result = (1..level).toList.fold(0, [acum, currentLevel |
			val Integer currentHeight = levelHeight.get(currentLevel) ?: 0
			acum + currentHeight + HEIGHT_SEPARATION_BETWEEN_CLASSES + adjustedHeight
		])
		result
	}
	
	def void adjustHeight(int level) {
		val currentHeight = levelHeight.get(level + 1) ?: 0
		val currentClassHeight = clazz.shapeHeight
		val newLevelHeight = Math.max(currentClassHeight, currentHeight)
		levelHeight.put(level + 1, newLevelHeight)
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
		
	def width() {
		120
	}

	def height() {
		130
	}
	
	def adjustedHeight() {
		if (objectsAndMixins > 0) 150 else 0
	}
	
	def getName() {
		clazz.name ?: ""
	}
	
}
