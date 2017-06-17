package org.uqbar.project.wollok.typesystem.constraints

import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.AnnotatedTypeRegistry
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.MethodTypeInfoImpl
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WParameter

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.lookupMethod
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo

class TypeVariablesRegistry {
	val Map<EObject, TypeVariable> typeVariables = newHashMap

	ConstraintBasedTypeSystem typeSystem
	AnnotatedTypeRegistry annotatedTypes

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
		this.annotatedTypes = new AnnotatedTypeRegistry(this)
	}

	// ************************************************************************
	// ** Creating type variables.
	// ************************************************************************
	def newTypeVariable(EObject obj) {
		new TypeVariable(obj) => [typeVariables.put(obj, it)]
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

	def newVoid(EObject it) {
		newTypeVariable
		beVoid
	}

	def beVoid(EObject it) {
		beSealed(WollokType.WVoid)
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
	def newSyntheticVar(String className) {
		new TypeVariable(null) => [
			addMinimalType(typeSystem.classType(null, className))
			beSealed
		]
	}

	// ************************************************************************
	// ** Retrieve type variables
	// ************************************************************************
	def allVariables() {
		typeVariables.values
	}

	def TypeVariable tvar(EObject obj) {
		typeVariables.get(obj) => [ typeVar |
			if (typeVar == null)
				throw new RuntimeException("I don't have type information for " + obj.debugInfo)
		]
	}

	// ************************************************************************
	// ** Method types
	// ************************************************************************
	def methodTypeInfo(ConcreteType type, String selector, List<TypeVariable> arguments) {
		annotatedTypes.get(type, selector) ?: new MethodTypeInfoImpl(this, type.lookupMethod(selector, arguments))
	}

	def methodTypeInfo(WClass container, String selector, List<WParameter> arguments) {
		annotatedTypes.get(container, selector) // Last parameter implies that we accept overriding abstract methods. 
		// If this where not true, it will be reported as an error elsewhere.
		// TODO Also, this will probably not work in the context of mixins.  
		?: new MethodTypeInfoImpl(this, container.lookupMethod(selector, arguments, true))
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	def fullReport() {
		typeVariables.values.forEach[println(fullDescription)]
	}
}
