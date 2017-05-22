package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.List
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Rectangular Figure modeling a class 
 * 
 * @author jfernandes
 * @author dodain
 */
@Accessors
class ClassModel extends AbstractModel {
	WMethodContainer component
	boolean imported = false
	
	new(WMethodContainer mc) {
		component = mc
		component.defineSize
	}
	
	override toString() {
		"ClassModel<" + component.name + ">"		
	}
	
	def locate(int level) {
		val subclasses = ClassModel.allComponents.clone.filter [ it.parent !== null && it.parent == this.component ].toList
		var initialXPosition = Math.max(levelWidth.get(level) ?: INITIAL_MARGIN, this.component.initialWidth)
		println("******************************************")
		println("Component " + component.name)
		println("Initial width " + component.initialWidth)
		val calculatedWidthOfSubclasses = subclasses.calculatedWidth
		val shapeWidth = this.component.shapeWidth
		val addedWidthOfShape = shapeWidth + WIDTH_SEPARATION_BETWEEN_ELEMENTS
		var int addedMargin = 0
		if (calculatedWidthOfSubclasses > 0) 
			addedMargin = ((calculatedWidthOfSubclasses - shapeWidth) / 2).intValue		
		val xPosition = initialXPosition + addedMargin
		println("Shape width " + shapeWidth)
		println("Added margin " + addedMargin) 
		println("calculatedWidthOfSubclasses " + calculatedWidthOfSubclasses)
		println("initialXPosition " + initialXPosition)
		println("xPosition " + xPosition)
		initialWidthForElement.put(this.component.name, initialXPosition)
		location = configuration.getLocation(this) ?: new Point(xPosition, level.calculatedHeight)
		level.adjustHeight
		levelWidth.put(level, initialXPosition + Math.max(addedWidthOfShape, calculatedWidthOfSubclasses))
	}

	def getCalculatedWidth(List<WMethodContainer> subclasses) {
		if (subclasses.empty) return 0
		val allSubclassesWidth = subclasses.map [ shapeWidth ].reduce [ a, b | a + b ]
		val margin = (subclasses.size + 1) * WIDTH_SEPARATION_BETWEEN_ELEMENTS
		allSubclassesWidth + margin
	}
	
	def getCalculatedHeight(int level) {
		val Integer result = (1..level).toList.fold(0, [acum, currentLevel |
			val Integer currentHeight = levelHeight.get(currentLevel) ?: 0
			acum + currentHeight + HEIGHT_SEPARATION_BETWEEN_ELEMENTS
		])
		result + adjustedHeight
	}
	
	def void adjustHeight(int level) {
		val currentHeight = levelHeight.get(level + 1) ?: 0
		val currentClassHeight = component.shapeHeight
		val newLevelHeight = Math.max(currentClassHeight, currentHeight)
		levelHeight.put(level + 1, newLevelHeight)
	}
	
	def int nextWidth(int subclassesCount) { 
		if (subclassesCount == 0) {
			return defaultWidth
		}
		subclassesCount * defaultWidth	
	}
		
	def getName() {
		component.name ?: ""
	}
	
}
