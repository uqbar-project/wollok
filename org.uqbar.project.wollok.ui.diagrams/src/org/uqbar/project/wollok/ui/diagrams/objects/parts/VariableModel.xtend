package org.uqbar.project.wollok.ui.diagrams.objects.parts

import java.util.Map
import org.eclipse.debug.core.model.IVariable
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
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
		this.size = new Dimension(75, 75)
		this.level = level
	}
	
	def createConnections(Map<IVariable, VariableModel> context) {
		variable.value?.variables.forEach[v| new Connection(v.name, this, get(context, v)) ]
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
	
	def getValueString() {
		if (variable.value == null) "null" else variable.value.valueString
	}
	
}