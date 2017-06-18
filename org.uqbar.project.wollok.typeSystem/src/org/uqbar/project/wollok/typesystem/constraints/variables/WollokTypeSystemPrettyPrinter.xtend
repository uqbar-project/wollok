package org.uqbar.project.wollok.typesystem.constraints.variables

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class WollokTypeSystemPrettyPrinter {
	// ************************************************************************
	// ** Expected type
	// ************************************************************************

	static def expectedType(TypeVariable it) { typeInfo.expected }
	
	static def dispatch expected(SimpleTypeInfo it) {
		maximalConcreteTypes.prettyPrint
	}
	
	static def dispatch expected(ClosureTypeInfo it) {
		throw new UnsupportedOperationException 
	}

	// ************************************************************************
	// ** Found type
	// ************************************************************************

	static def foundType(TypeVariable it) { typeInfo.found }

	static def dispatch found(SimpleTypeInfo it) {
		minimalConcreteTypes.entrySet.findFirst[value == Error].key.toString
	}

	static def dispatch found(ClosureTypeInfo it) {
		throw new UnsupportedOperationException 
	}

	// ************************************************************************
	// ** Pretty print max types
	// ************************************************************************

	static def prettyPrint(MaximalConcreteTypes it) {
		if (maximalConcreteTypes.size > 1)
			maximalConcreteTypes.toString
		else
			maximalConcreteTypes.findFirst[true].toString
	}
}
