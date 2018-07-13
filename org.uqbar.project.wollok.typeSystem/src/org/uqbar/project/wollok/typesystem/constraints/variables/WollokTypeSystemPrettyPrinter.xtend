package org.uqbar.project.wollok.typesystem.constraints.variables

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class WollokTypeSystemPrettyPrinter {
	// ************************************************************************
	// ** Expected type
	// ************************************************************************

	static def expectedType(TypeVariable it) { typeInfo.expected(it) }
	
	static def dispatch expected(GenericTypeInfo it, TypeVariable user) {
		maximalConcreteTypes?.prettyPrint ?: getType(user).toString
	}
	
	static def dispatch expected(TypeInfo it, TypeVariable user) {
		throw new UnsupportedOperationException 
	}

	// ************************************************************************
	// ** Found type
	// ************************************************************************

	static def foundType(TypeVariable it) { typeInfo.found }

	static def dispatch found(GenericTypeInfo it) {
		minTypes.entrySet.findFirst[value == Error]?.key?.toString
	}

	static def dispatch found(TypeInfo it) {
		throw new UnsupportedOperationException 
	}

	// ************************************************************************
	// ** Pretty print max types
	// ************************************************************************

	static def prettyPrint(MaximalConcreteTypes it) {
		if (maximalConcreteTypes.size == 1)
			maximalConcreteTypes.findFirst[true].toString
		else
			maximalConcreteTypes.toString
	}
}
