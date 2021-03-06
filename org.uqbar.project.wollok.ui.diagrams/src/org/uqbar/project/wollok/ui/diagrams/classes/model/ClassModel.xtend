package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.List
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * Model of a class figure.
 * 
 * @author jfernandes
 * @author dodain
 */
@Accessors
class ClassModel extends AbstractModel {
	boolean imported = false
	
	new(WMethodContainer mc) {
		super(mc)
	}
	
	override toString() {
		"ClassModel<" + this.label + ">"		
	}
	
	def locate(int level) {
		val subclasses = ClassModel.allComponents.filter [ it.parent !== null && it.parent.equals(this.component) ].toList
		var initialXPosition = Math.max(levelWidth.get(level) ?: INITIAL_MARGIN, this.initialWidth)
		val calculatedWidthOfSubclasses = subclasses.calculatedWidth
		val shapeWidth = this.shapeWidth
		val addedWidthOfShape = shapeWidth + WIDTH_SEPARATION_BETWEEN_ELEMENTS
		var int addedMargin = 0
		if (calculatedWidthOfSubclasses > 0) 
			addedMargin = ((calculatedWidthOfSubclasses - shapeWidth) / 2).intValue
		val xPosition = initialXPosition + addedMargin
		initialWidthForElement.put(this.component.identifier, initialXPosition)
		location = configuration.getLocation(this) ?: new Point(xPosition, level.calculatedHeight)
		level.adjustHeight
		levelWidth.put(level, initialXPosition + Math.max(addedWidthOfShape, calculatedWidthOfSubclasses))
	}
	
	def getCalculatedWidth(List<WMethodContainer> subclasses) {
		if (subclasses.empty) return 0
		// TODO: Put in a buffered map new ClassModel(it).shapeWidth?
		val allSubclassesWidth = subclasses.map [ new ClassModel(it).shapeWidth ].reduce [ a, b | a + b ]
		val margin = (subclasses.size + 1) * WIDTH_SEPARATION_BETWEEN_ELEMENTS
		allSubclassesWidth + margin
	}
	
	def getCalculatedHeight(int level) {
		val Integer result = (1..level).toList.fold(0, [acum, currentLevel |
			val Integer currentHeight = levelHeight.get(currentLevel) ?: 0
			acum + currentHeight + HEIGHT_SEPARATION_BETWEEN_ELEMENTS
		])
		result + maxHeight
	}
	
	def void adjustHeight(int level) {
		val currentHeight = levelHeight.get(level + 1) ?: 0
		val currentClassHeight = this.shapeHeight
		val newLevelHeight = Math.max(currentClassHeight, currentHeight)
		levelHeight.put(level + 1, newLevelHeight)
	}
	
	def int nextWidth(int subclassesCount) { 
		if (subclassesCount == 0) {
			return defaultWidth
		}
		subclassesCount * defaultWidth	
	}

}
