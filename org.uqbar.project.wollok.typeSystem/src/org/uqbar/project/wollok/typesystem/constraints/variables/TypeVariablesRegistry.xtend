package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List

import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.AnnotatedTypeRegistry
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.MethodTypeInfo
import org.uqbar.project.wollok.wollokDsl.WClass

import static org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo.ELEMENT

import static extension org.eclipse.emf.ecore.util.EcoreUtil.getURI
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.lookupMethod
import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.isCoreObject
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*

class TypeVariablesRegistry {
	val Map<URI, TypeVariable> typeVariables = newHashMap
	val Map<URI, ClassParameterTypeVariable> typeParameters = newHashMap
	val Logger log = Logger.getLogger(this.class)
	

	@Accessors(PUBLIC_GETTER)
	ConstraintBasedTypeSystem typeSystem

	@Accessors
	AnnotatedTypeRegistry annotatedTypes

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
	}

	def register(TypeVariable it) {
		// Only register variables which have an owner. Variables without an owner have are "synthetic", i.e. 
		// they have no representation in code. Proper handling of synthetic variables is yet to be polished
		if (owner !== null) typeVariables.put(owner.URI, it)
		return it
	}

	def register(ClassParameterTypeVariable it) {
		// Only register variables which have an owner. Variables without an owner have are "synthetic", i.e. 
		// they have no representation in code. Proper handling of synthetic variables is yet to be polished
		if (owner !== null) typeParameters.put(owner.URI, it)
		return it
	}
	
	// ************************************************************************
	// ** Creating type variables.
	// ************************************************************************
	def newTypeVariable(EObject owner) {
		TypeVariable.simple(owner).register
	}

	def newClosure(EObject owner, List<ITypeVariable> parameters, ITypeVariable expression) {
		TypeVariable.closure(owner, parameters, expression).register
	}

	/**
	 * This should be a special case of a generic type variable, for now collections are the only generic types.
	 */
	def newCollection(EObject owner, ConcreteType collectionType) {
		TypeVariable.generic(owner, #[ELEMENT]) => [
			addMinType(collectionType)
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
		newTypeVariable => [beSealed(type)]
	}

	def beVoid(EObject it) {
		it.tvar.beVoid
	}

	def beSealed(EObject it, WollokType type) {
		tvar => [beSealed(type)]
	}

	def beSealed(TypeVariable it, WollokType type) {
		addMinType(type)
		beSealed
	}

	// ************************************************************************
	// ** Synthetic type variables
	// ************************************************************************
	def newSyntheticVar(WollokType type) {
		// TODO This should disappear when we finish the new type annotations.
		TypeVariable.synthetic => [
			addMinType(type)
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
		typeVariables.get(obj.URI) => [ if (it === null) {
			throw new TypeSystemException("Missing type information for " + obj.debugInfoInContext)
		}]
	}
	
	def ITypeVariable tvarOrParam(EObject obj) {
		typeVariables.get(obj.URI) ?: 
			typeParameters.get(obj.URI) => [ if (it === null) {
				throw new TypeSystemException("Missing type information for " + obj.debugInfoInContext)
			}]
	}
	
	def type(EObject obj) {
		typeVariables.get(obj.URI)?.type
	}

	// ************************************************************************
	// ** Method types
	// ************************************************************************
	def methodTypeInfo(ConcreteType type, String selector, List<TypeVariable> arguments) {
		new MethodTypeInfo(this, type.lookupMethod(selector, arguments))
	}

	def methodTypeInfo(WClass container, String selector, List<?> arguments) {
		new MethodTypeInfo(this, container.lookupMethod(selector, arguments, true))
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	def fullReport() {
		typeVariables.values.forEach[
			if (!owner.isCoreObject) log.debug(descriptionForReport)
		]
	}
	
}
