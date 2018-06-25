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
	
	def paramTypes(GenericTypeInstance it) {
		GenericTypeInfo.PARAMS(paramCount).map[ paramName | typeParameters.get(paramName).type ]
	}
	
	def returnType(GenericTypeInstance it) {
		typeParameters.get(GenericTypeInfo.RETURN).type
	}
	
	def paramCount(GenericTypeInstance it) {
		typeParameters.size - 1
	}
}