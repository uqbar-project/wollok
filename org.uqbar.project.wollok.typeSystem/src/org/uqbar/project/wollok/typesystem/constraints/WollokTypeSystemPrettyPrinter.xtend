package org.uqbar.project.wollok.typesystem.constraints

import static org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeState.*

class WollokTypeSystemPrettyPrinter {
	static def expectedType(TypeVariable it) { maximalConcreteTypes.prettyPrint }

	static def foundType(TypeVariable it) {
		minimalConcreteTypes.entrySet.findFirst[value == Error].key.toString
	}

	static def prettyPrint(MaximalConcreteTypes it) {
		if (maximalConcreteTypes.size > 1)
			maximalConcreteTypes.toString
		else
			maximalConcreteTypes.findFirst[true].toString
	}
}
