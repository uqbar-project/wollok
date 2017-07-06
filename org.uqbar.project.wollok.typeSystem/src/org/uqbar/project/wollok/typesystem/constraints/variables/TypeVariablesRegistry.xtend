package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.AnnotatedTypeRegistry
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.MethodTypeInfo
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WParameter

import static org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo.ELEMENT

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.lookupMethod
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo
import org.eclipse.xtend.lib.annotations.Accessors

class TypeVariablesRegistry {
	val Map<EObject, TypeVariable> typeVariables = newHashMap
	val Map<EObject, ClassParameterTypeVariable> typeParameters = newHashMap

	@Accessors(PUBLIC_GETTER)
	ConstraintBasedTypeSystem typeSystem

	@Accessors
	AnnotatedTypeRegistry annotatedTypes

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
	}

	def register(TypeVariable it) {
		typeVariables.put(owner, it)
		return it
	}

	def register(ClassParameterTypeVariable it) {
		typeParameters.put(owner, it)
		return it
	}
	
	// ************************************************************************
	// ** Creating type variables.
	// ************************************************************************
	def newTypeVariable(EObject owner) {
		TypeVariable.simple(owner).register
	}

	def newClosure(EObject owner, List<TypeVariable> parameters, TypeVariable expression) {
		TypeVariable.closure(owner, parameters, expression).register
	}

	/**
	 * This should be a special case of a generic type variable, for now collections are the only generic types.
	 */
	def newCollection(EObject owner, ConcreteType collectionType) {
		TypeVariable.generic(owner, #[ELEMENT]) => [
			addMinimalType(collectionType)
			beSealed
			register
		]
	}

	def newVoid(EObject owner) {
		TypeVariable.newVoid(owner).register
	}


	def newWithSubtype(EObject it, EObject... subtypes) {
		newTypeVariable => [subtypes.forEach[subtype|it.beSupertypeOf(subtype.tvar)]]
	}

	def newWithSupertype(EObject it, EObject... supertypes) {
		newTypeVariable => [supertypes.forEach[supertype|it.beSubtypeOf(supertype.tvar)]]
	}

	def newSealed(EObject it, WollokType type) {
		newTypeVariable
		beSealed(type)
	}

	def beVoid(EObject it) {
		it.tvar.beVoid
	}

	def beSealed(EObject it, WollokType type) {
		tvar => [
			addMinimalType(type)
			beSealed
		]
	}

	// ************************************************************************
	// ** Synthetic type variables
	// ************************************************************************
	def newSyntheticVar(WollokType type) {
		// TODO This should disappear when we finish the new type annotations.
		TypeVariable.synthetic => [
			addMinimalType(type)
			beSealed
		]
	}

	def newClassParameterVar(EObject owner, String paramName) {
		TypeVariable.classParameter(owner, paramName) => [
			registry = this 
			register
		]
	}

	// ************************************************************************
	// ** Retrieve type variables
	// ************************************************************************
	def allVariables() {
		typeVariables.values
	}

	/**
	 * This method returns types that are not type parameters. 
	 * If you want to be able to handle also type parameters, you have to use {@link #tvarOrParam}
	 */
	def TypeVariable tvar(EObject obj) {
		typeVariables.get(obj) => 
			[ if (it==null) throw new RuntimeException("I don't have type information for " + obj.debugInfo) ]
	}
	
	def ITypeVariable tvarOrParam(EObject obj) {
		typeVariables.get(obj) ?: 
			typeParameters.get(obj) =>
				[ if (it==null) throw new RuntimeException("I don't have type information for " + obj.debugInfo) ]
	}

	// ************************************************************************
	// ** Method types
	// ************************************************************************
	def methodTypeInfo(ConcreteType type, String selector, List<TypeVariable> arguments) {
		new MethodTypeInfo(this, type.lookupMethod(selector, arguments))
	}

	def methodTypeInfo(WClass container, String selector, List<WParameter> arguments) {
		new MethodTypeInfo(this, container.lookupMethod(selector, arguments, true))
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	def fullReport() {
		typeVariables.values.forEach[println(descriptionForReport)]
	}
	
}
