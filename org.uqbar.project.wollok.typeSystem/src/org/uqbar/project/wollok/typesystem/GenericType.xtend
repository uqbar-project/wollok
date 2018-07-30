package org.uqbar.project.wollok.typesystem

import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInstance
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable

import static extension org.uqbar.project.wollok.utils.XtendExtensions.*
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

interface TypeFactory {
	def TypeSystem getTypeSystem()
	def ConcreteType instanceFor(TypeVariable owner)
}

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
class GenericType implements TypeFactory {
	ClassInstanceType baseType
	String[] typeParameterNames
		
	new(WClass clazz, TypeSystem typeSystem, String... typeParameterNames) {
		baseType = new ClassInstanceType(clazz, typeSystem)
		this.typeParameterNames = typeParameterNames
	}
	
	override getTypeSystem() { baseType.typeSystem }
	
	/**
	 * @param futureOwner The type variable for which the resulting type (a GenericTypeInstance will be used.
	 * 					  The dependent type variables of the created type instance require a parent type variable.
	 */
	override GenericTypeInstance instanceFor(TypeVariable tvar) {
		instance(typeParameterNames.toInvertedMap[ name | registry.newParameter(tvar.owner, name)])
	}
	
	def instance(Map<String, TypeVariable> typeParameters) {
		new GenericTypeInstance(this, typeParameters)
	} 
	
	def schema(Map<String, ITypeVariable> typeParameters) {
		new GenericTypeSchema(this, typeParameters)
	}
	
	def getRegistry() {
		(baseType.typeSystem as ConstraintBasedTypeSystem).registry		
	}
	
	def toString(GenericTypeInstance instance)
		'''«baseType.toString»<«typeParameterNames.map[instance.param(it).type].join(', ')»>''' 
	
	override toString()
		'''«baseType.toString»<«typeParameterNames.join(', ')»>''' 
	
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