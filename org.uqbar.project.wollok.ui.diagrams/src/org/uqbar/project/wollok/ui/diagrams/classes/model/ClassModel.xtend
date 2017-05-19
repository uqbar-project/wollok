package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.List
import java.util.Map
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants

import static extension java.lang.Integer.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

/**
 * A rectangular shape.
 * 
 * @author jfernandes
 */
@Accessors
class ClassModel extends Shape {
	var int objectsAndMixins = 0
	static List<WMethodContainer> allComponents = newArrayList
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
			
	WMethodContainer component
	boolean imported = false
	
	static def void init(List<WMethodContainer> _classes) {
		levelHeight = newHashMap
		levelWidth = newHashMap
		initialWidthForClass = newHashMap
		allComponents = _classes
	}
	
	new(WMethodContainer mc) {
		component = mc
		defineSize
		objectsAndMixins = NamedObjectModel.objectsCount + MixinModel.mixinsCount
	}
	
	def void defineSize() {
		size = configuration.getSize(this) ?: new Dimension(component.shapeWidth, component.shapeHeight)
	}
	
	def int shapeWidth(WMethodContainer mc) {
		CLASS_WIDTH + (mc.allWidths.reduce [ a, b | a.max(b) ] * LETTER_WIDTH)
	}
	
	def allWidths(WMethodContainer mc) {
		val result = newArrayList
		if (configuration.showVariables) {
			result.addAll(mc.variables.map [ it.name?.length ])
		}
		result.addAll(mc.methods.map [ it.name?.length ])
		result.add(mc.name.length)
		result
	}
	
	def int shapeHeight(WMethodContainer mc) {
		(mc.variablesSize + mc.methods.size) * FILE_HEIGHT + CLASS_HEIGHT
	}
	
	def int getVariablesSize(WMethodContainer mc) {
		if (configuration.showVariables) mc.variables.size else 0
	}

	override toString() {
		"ClassModel<" + component.name + ">"		
	}
	
	def locate(int level) {
		val subclasses = org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel.allComponents.clone.filter [ it.parent !== null && it.parent == this.component ].toList
		val calculatedWidthOfSubclasses = subclasses.calculatedWidth
		var initialWidth = Math.max(levelWidth.get(level) ?: INITIAL_MARGIN, this.component.initialWidth)
		val addedWidthOfShape = this.component.shapeWidth + WIDTH_SEPARATION_BETWEEN_CLASSES
		val xPosition = initialWidth + (calculatedWidthOfSubclasses / 2).intValue
		initialWidthForClass.put(this.component.name, initialWidth)
		location = configuration.getLocation(this) ?: new Point(xPosition, level.calculatedHeight)
		level.adjustHeight
		levelWidth.put(level, initialWidth + addedWidthOfShape + calculatedWidthOfSubclasses)
	}
	
	def int getInitialWidth(WMethodContainer mc) {
		if (mc.parent === null) return 0
		val parentClassName = mc.parent.name ?: ""
		if (parentClassName.equals(WollokConstants.ROOT_CLASS)) return 0
		initialWidthForClass.get(parentClassName) ?: 0
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
		val currentClassHeight = component.shapeHeight
		val newLevelHeight = Math.max(currentClassHeight, currentHeight)
		levelHeight.put(level + 1, newLevelHeight)
	}
	
	def getCalculatedWidth(List<WMethodContainer> subclasses) {
		subclasses.indexOf(this.component)
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
		component.name ?: ""
	}

}
