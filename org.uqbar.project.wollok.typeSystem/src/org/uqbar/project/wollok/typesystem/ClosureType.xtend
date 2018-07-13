package org.uqbar.project.wollok.typesystem

import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance
import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * Type for generic closures
 * 
 * @author jfernandes
 * @author npasserini
 */
class ClosureType extends GenericType {
	
	new(WClass clazz, TypeSystem typeSystem, String... typeParameterNames) {
		super(clazz, typeSystem, typeParameterNames)
	}

	override toString(GenericTypeInstance it) '''{(«paramTypes?.map[name].join(',')») => «returnType?.name»}'''
	
	// ************************************************************************
	// ** Static helpers
	// ************************************************************************
	
	static def paramTypes(GenericTypeInstance it) {
		paramTypeVariables.map[type]
	}
	
	static def returnType(GenericTypeInstance it) {
		returnTypeVariable.type
	}

	static def paramTypeVariables(GenericTypeInstance it) {
		GenericTypeInfo.PARAMS(paramCount).map[ paramName | typeParameters.get(paramName) ]
	}
	
	static def returnTypeVariable(GenericTypeInstance it) {
		typeParameters.get(GenericTypeInfo.RETURN)
	}
	
	static def paramCount(GenericTypeInstance it) {
		typeParameters.size - 1
	}
}
