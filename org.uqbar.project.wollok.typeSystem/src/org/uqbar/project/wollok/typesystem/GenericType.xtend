package org.uqbar.project.wollok.typesystem

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable

import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * This is the abstract definition of a GenericType, e.g List<T>. 
 * It consists of a basic type, in the example the type List, 
 * and a set of type parameter names, in the example there is only one parameter, named T.
 * 
 * This is not an actual type but a template for creating types, which is done by sending the #instance message,
 * which creates a new type with actual type variables for each type parameter defined in the template. 
 * 
 * @author npasserini
 */
@Accessors
class GenericType extends ClassBasedWollokType {
	String[] typeParameterNames
	
	new(WClass clazz, TypeSystem typeSystem, String... typeParameterNames) {
		super(clazz, typeSystem)
		this.typeParameterNames = typeParameterNames
	}
	
	def instance() {
		instance(typeParameterNames.toInvertedMap[TypeVariable.synthetic])
	}
	
	def instance(Map<String, TypeVariable> typeParameters) {
		new GenericTypeInstance(this, typeParameters)
	} 
	
	def schema(Map<String, ITypeVariable> typeParameters) {
		new GenericTypeSchema(this, typeParameters)
	}
	
	def toString(GenericTypeInstance instance) {
		'''«toString»<«typeParameterNames.map[instance.param(it).type].join(', ')»>''' 
	}
	
}

class GenericTypeSchema {
	@Accessors(PUBLIC_GETTER)
	GenericType rawType
	
	@Accessors(PUBLIC_GETTER)
	Map<String, ITypeVariable> typeParameters
	
	new(GenericType type, Map<String, ITypeVariable> typeParameters) {
		this.rawType = type
		this.typeParameters = typeParameters
	}	

	def instanceFor(TypeVariable variable) {
		new GenericTypeInstance(rawType, typeParameters.doMapValues[instanceFor(variable)])
	}

	def instanceFor(ConcreteType concreteType) {
		new GenericTypeInstance(rawType, typeParameters.doMapValues[instanceFor(concreteType)])
	}	
}