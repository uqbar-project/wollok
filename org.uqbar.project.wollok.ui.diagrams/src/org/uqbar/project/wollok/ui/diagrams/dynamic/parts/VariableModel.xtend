package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.util.Map
import java.util.Random
import org.eclipse.debug.core.model.IVariable
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.PrecisionPoint
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

/**
 * 
 * @author jfernandes
 */
 @Accessors
class VariableModel extends Shape {
	IVariable variable
	int level
	
	new(IVariable variable, int level) {
		this.variable = variable
		this.size = calculateSize()
		this.level = level
	}
	
	def calculateSize() {
		if (isNumeric)
			new Dimension(50, 50)
		else if (isList)
			new Dimension(50, 25)
		else
			new Dimension(75, 75)
	}
	
	def void createConnections(Map<IVariable, VariableModel> context) {
		variable.value?.variables.forEach[v| new Connection(v.name, this, get(context, v), RelationType.INHERITANCE) ]
	}
	
	def get(Map<IVariable, VariableModel> map, IVariable variable) {
		if (map.containsKey(variable)) 
			map.get(variable)
		else {
			new VariableModel(variable, this.level + 1) => [
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
		if (variable.value === null) false else originalValueString.matches("^List \\(id.*")
	}
	
	def moveCloseTo(Shape shape) {
		// a random value in [0, 2PI] for the angle in radians
		val angle = new Random().nextFloat() * 2 * Math.PI 
		// length of the line
		val magnitude = 100.0f
		
		this.location = new PrecisionPoint(shape.location.x + Math.cos(angle) * magnitude, shape.location.y + Math.sin(angle) * magnitude)
	}
	
}
