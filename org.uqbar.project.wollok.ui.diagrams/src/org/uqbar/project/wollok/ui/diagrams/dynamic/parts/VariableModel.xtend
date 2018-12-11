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
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView

/**
 * 
 * @author jfernandes
 * @author dodain        Major refactor: integrate with REPL online and enhance drawing algorithm
 * 
 */
 @Accessors
class VariableModel extends Shape {
	
	/** 
	 * Fast access to shapes by level 
	 * 0 = root
	 * 1 = instance variables of objects of root 0, and so on...
	 */
	static Map<Integer, List<VariableModel>> shapesSameLevel = new HashMap()
	
	/** 
	 * All shapes by variable name 
	 */
	static Map<String, VariableModel> allShapes = new HashMap()

	static int HEIGHT_SIZE = 140
	static int HEIGHT_MARGIN = 40
	static int WIDTH_SIZE = 140
	static int WIDTH_MARGIN = 50
	static int MIN_WIDTH = 25
	static int LETTER_WIDTH = 12
	static int MAX_ELEMENT_WIDTH = 200
	
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
		this.calculateInitialLocation(level)
	}

	static def getVariableModelFor(IVariable variable, int level) {
		var shape = allShapes.get(variable.toString)
		// quick way to determine if we should re-draw the shape
		if (shape === null) {
			shape = new VariableModel(variable, level)
			// toString is in fact the identifier of the variable
			// hacked way to avoid duplicates
			allShapes.put(variable.toString, shape)
		}
		shape
	}
	
	public static def initVariableShapes() {
		shapesSameLevel = new HashMap()
		allShapes = new HashMap()
	}
	
	def void calculateInitialLocation(int level) {
		val siblings = shapesSameLevel.get(level) ?: newArrayList
		siblings.add(this)
		shapesSameLevel.put(level, siblings)
		this.location = new Point(WIDTH_MARGIN + level * WIDTH_SIZE, HEIGHT_MARGIN + siblings.size * HEIGHT_SIZE)
	}
	
	def calculateSize(IVariable variable) {
		if (isNumeric)
			new Dimension(50, 50)
		else if (isCollection)
			new Dimension(50, 25)
		else {
			val size = Math.max(Math.min(valueString.length * LETTER_WIDTH, MAX_ELEMENT_WIDTH), MIN_WIDTH)
			new Dimension(size, Math.min(size, 75))
		}
	}
	
	def void createConnections(Map<IVariable, VariableModel> context) {
		variable?.value?.variables?.forEach[v| new Connection(v.name, this, get(context, v), RelationType.ASSOCIATION) ]
	}
	
	def get(Map<IVariable, VariableModel> map, IVariable variable) {
		if (map.containsKey(variable)) {
			map.get(variable)
		}
		else {
			// TODO: Conseguir los shapes de la corrida anterior que están en stackFrameEditPart
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
	
	def isNumeric() {
		if (variable.value === null) false else valueString.matches("^-?\\d+(\\.\\d+)?$")
	} 
	
	def isList() {
		if (variable.value === null) false else originalValueString.matches("^List.*")
	}
	
	def isSet() {
		if (variable.value === null) false else originalValueString.matches("^Set.*")
	}
	
	def isCollection() { isList || isSet }
	
	def moveCloseTo(Shape shape) {
		// a random value in [0, 2PI] for the angle in radians
		val angle = new Random().nextFloat() * 2 * Math.PI 
		// length of the line
		val magnitude = 100.0f
		
		this.location = new PrecisionPoint(shape.location.x + Math.cos(angle) * magnitude, shape.location.y + Math.sin(angle) * magnitude)
	}

	override toString() {
		"VariableModel " + this.variable.toString + " = " + this.valueString
	}
	
}
