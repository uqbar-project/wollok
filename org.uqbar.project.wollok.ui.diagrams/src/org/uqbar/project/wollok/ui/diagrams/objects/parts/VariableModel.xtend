package org.uqbar.project.wollok.ui.diagrams.objects.parts

import java.util.Map
import org.eclipse.debug.core.model.IVariable
import org.eclipse.draw2d.geometry.Dimension
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

/**
 * 
 * @author jfernandes
 */
class VariableModel extends Shape {
	IVariable variable
	
	new(IVariable variable) {
		this.variable = variable
		this.size = new Dimension(75, 75)
	}
	
	def createConnections(Map<IVariable, VariableModel> context) {
		variable.value?.variables.forEach[v| new Connection(this, get(context, v)) ]
	}
	
	def get(Map<IVariable, VariableModel> map, IVariable variable) {
		if (map.containsKey(variable)) 
			map.get(variable)
		else
			new VariableModel(variable) => [
				map.put(variable, it)
			]
	}
	
	def getValueString() {
		if (variable.value == null) "null" else variable.value.valueString
	}
	
}