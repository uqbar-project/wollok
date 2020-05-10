package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Random
import org.eclipse.debug.core.model.IVariable
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.PrecisionPoint
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.debugger.model.WollokVariable
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration

import static extension org.uqbar.project.wollok.ui.diagrams.dynamic.parts.DynamicDiagramUtils.*
import static extension org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * 
 * @author jfernandes
 * @author dodain        Major refactor: integrate with REPL online and enhance drawing algorithm
 * 
 */
 @Accessors
class VariableModel extends Shape {
	
	/** 
	 * Height for every root variable
	 * 0 = First variable, and corresponding max height 
	 */
	static ShapeHeightHandler shapeHeightHandler
	
	/** 
	 * All shapes by variable name 
	 */
	static Map<String, VariableModel> allVariables = new HashMap()
	
	IVariable variable
	int level
	int brothers = 0
	
	new(IVariable variable, int level) {
		val variableValues = DynamicDiagramView.variableValues
		val fixedVariable = variableValues.get(variable.toString)
		if (fixedVariable !== null && variable.value === null) {
			this.variable = new WollokVariable(null, fixedVariable)
		} else {
			this.variable = variable
		}
		this.level = level
		this.size = variable.calculateSize()
	}

	static def VariableModel getVariableModelFor(IVariable variable, int level) {
		var variableModel = VariableModel.allVariables.get(variable.toString)
		// quick way to determine if we should re-draw the shape
		if (variableModel === null) {
			variableModel = new VariableModel(variable, level)
			// toString is in fact the identifier of the variable
			// hacked way to avoid duplicates
			VariableModel.allVariables.put(variable.toString, variableModel)
		}
		variableModel => [
			shapeHeightHandler.addVariableModel(it, level)
			calculateInitialLocation(level)
		]
	}
	
	static def initVariableShapes() {
		shapeHeightHandler = new ShapeHeightHandler()
		VariableModel.allVariables = new HashMap()
	}
	
	def int childrenSizeForHeight() {
		variable.childrenSizeForHeight
	}

	def int indexOfChild(VariableModel v) {
		if (variable.value === null) return -1
		variable.value.variables.indexOf(v.variable)	
	}
	
	def IVariable getChild(int index) {
		if (variable.value === null) return null
		variable.value.variables.get(index)
	}

	def void calculateInitialLocation(int level) {
		val manualValue = configuration.getLocation(this)
		if (manualValue === null) {
			val originalLocation = new Point(WIDTH_MARGIN + level * WIDTH_SIZE, shapeHeightHandler.getHeight(this))
			this.location = originalLocation
		} else {
			this.location = manualValue
		}
	}
	
	def calculateSize(IVariable variable) {
		val manualValue = configuration.getSize(this)
		if (manualValue !== null) return manualValue

		if (isNumeric)
			new Dimension(50, DEFAULT_HEIGHT)
		else if (isCollection)
			new Dimension(50, 30)
		else {
			val size = Math.max(Math.min(valueString.length * LETTER_WIDTH, MAX_ELEMENT_WIDTH), MIN_WIDTH)
			new Dimension(size, Math.min(size, DEFAULT_HEIGHT))
		}
	}
	
	def void createConnections(Map<IVariable, VariableModel> context) {
		if (variable === null || variable.value === null || variable.value.variables === null) return;
		val allVariables = variable.value.variables.toList
		val sameReferences = newHashMap
		allVariables.forEach [ v |
			val destination = get(context, v)
			val variables = sameReferences.get(destination)
			if (variables === null) {
				sameReferences.put(destination, newArrayList(v.name))
			} else {
				variables.add(v.name)
				sameReferences.put(destination, variables)
			}
		]
		allVariables.toList.forEach [v| 
			val destination = get(context, v)
			new Connection(sameReferences.get(destination).join(", "), this, destination, RelationType.ASSOCIATION) 
		]
	}
	
	def get(Map<IVariable, VariableModel> map, IVariable variable) {
		if (map.containsKey(variable)) {
			map.get(variable)
		}
		else {
			VariableModel.getVariableModelFor(variable, this.level + 1) => [
				map.put(variable, it)
				// go deep (recursion)
				it.createConnections(map)
			]
		}
	}
	
	def String getValueString() {
		if (variable.value === null) 
			"null"
		else if (isList)
			"List"
		else if (isSet)
			"Set"
		else 
			originalValueString()
	}
	
	def originalValueString() {
		variable.value.valueString
	}
	
	def isNumeric() { if (variable.value === null) false else valueString.matches("^-?\\d+(\\.\\d+)?$") }
	def isList() { typeName.equalsIgnoreCase(LIST) }
	def isSet() { typeName.equalsIgnoreCase(SET) }
	def isString() { typeName.equalsIgnoreCase(STRING) }
	def isNative() { #[BOOLEAN, DATE, PAIR, RANGE].contains(typeName) }
	def isCollection() { isList || isSet }
	
	def isUserDefined() {
		if (variable.value === null) return false
		!typeName.startsWith("wollok.")
	}
	
	def typeName() {
		if (variable.value === null) return "null"
		variable.value.referenceTypeName	
	}
	
	@Deprecated
	def moveCloseTo(Shape shape) {
		// a random value in [0, 2PI] for the angle in radians
		val angle = new Random().nextFloat() * 2 * Math.PI 
		// length of the line
		val magnitude = 100.0f
		
		this.location = new PrecisionPoint(shape.location.x + Math.cos(angle) * magnitude, shape.location.y + Math.sin(angle) * magnitude)
	}

	override configuration() {
		DynamicDiagramConfiguration.instance
	}
	
	override toString() {
		"VariableModel " + this.variable.toString + " = " + this.valueString
	}

	def int nextLocationForSibling() {
		variable.nextLocationForSibling(nextLocationForChild, this.size.height)
	}
	
	def int nextLocationForChild() {
		this.YItShouldHave
	}

	def int getYItShouldHave() {
		shapeHeightHandler.getYItShouldHave(this)
	}
	
	def int y() {
		this.bounds.top.y
	}

	def int getYValueForAnchor() {
		YItShouldHave + (this.size.height / 2) - PADDING
	}
		
}

class ShapeHeightHandler {
	List<VariableModel> rootVariables = newArrayList
	Map<IVariable, Map<IVariable, Integer>> allSizes = newHashMap
	Map<IVariable, List<VariableModel>> allParents = newHashMap
	Map<IVariable, Integer> parentsVisited = newHashMap
	Map<IVariable, VariableModel> allVariables = newHashMap
	
	def getHeight(VariableModel variableModel) {
		variableModel.currentHeight
	}
	
	def int getCurrentHeight(VariableModel variableModel) {
		var current = parentsVisited.get(variableModel.variable)		
		val parent = allParents.get(variableModel.variable)?.get(current)
		var height = 0
		// TODO: Generate two strategies for root variables and non-root ones
		if (parent === null) {
			val upTo = rootVariables.indexOf(variableModel)
			val hasPrevious = upTo > 0
			if (hasPrevious) {
				val sibling = rootVariables.get(upTo - 1)
				height = sibling.nextLocationForSibling
			}
		} else {
			val mapParent = allSizes.get(parent.variable) as Map<IVariable, Integer> ?: newHashMap
			height = parent.nextLocationForChild
			val upTo = parent.indexOfChild(variableModel)
			val hasPrevious = upTo > 0
			if (hasPrevious) {
				val siblingVariable = parent.getChild(upTo - 1)
				val originalHeight = mapParent.get(siblingVariable) ?: parent.y + (DEFAULT_HEIGHT * upTo)
				val sibling = allVariables.get(siblingVariable)
				val siblingHeight = if (sibling === null) DEFAULT_HEIGHT else sibling.size.height
				height = nextLocationForSibling(siblingVariable, originalHeight, siblingHeight)
				current++
				parentsVisited.put(variableModel.variable, current)
			}
			allSizes.get(parent.variable).put(variableModel.variable, height)
			mapParent.put(variableModel.variable, new Integer(height))
		}
		return height
	}

	def getYItShouldHave(VariableModel variableModel) {
		val parents = allParents.get(variableModel.variable)
		val index = parentsVisited.get(variableModel.variable)
		if (parents === null || parents.size >= index) {
			return variableModel.y
		}
		val parent = parents.get(index)
		if (parent === null) {
			variableModel.y
		} else {
			allSizes.get(parent.variable).get(variableModel.variable)
		}
	}
	
	def addVariableModel(VariableModel variableModel, int level) {
		allSizes.put(variableModel.variable, newHashMap)
		allVariables.put(variableModel.variable, variableModel)
		parentsVisited.put(variableModel.variable, 0)
		if (variableModel.variable.value === null) return;
		variableModel.variable.value.variables.forEach [
			val variables = allParents.get(it) as List<VariableModel> ?: newArrayList
			variables.add(variableModel)
			allParents.put(it, variables)
			allSizes.put(it, newHashMap)
			parentsVisited.put(it, 0)
		]
		if (level === 0) {
			rootVariables.add(variableModel)
		}
	}

}
