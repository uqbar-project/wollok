package org.uqbar.project.wollok.typesystem.constraints

import org.uqbar.project.wollok.typesystem.constraints.TypeVariable.ConcreteTypeState

class WollokTypeSystemPrettyPrinter {
	static def expectedType(TypeVariable it) { maximalConcreteTypes.prettyPrint }

	static def foundType(TypeVariable it) {
		minimalConcreteTypes.entrySet.findFirst[value == ConcreteTypeState.Error].key.toString
	}

	static def prettyPrint(MaximalConcreteTypes it) {
		if (maximalConcreteTypes.size > 1) 
			maximalConcreteTypes.toString
			else maximalConcreteTypes.findFirst[true].toString
	}
}
