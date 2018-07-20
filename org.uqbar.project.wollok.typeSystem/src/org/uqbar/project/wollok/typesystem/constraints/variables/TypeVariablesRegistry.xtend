package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.AnnotatedTypeRegistry
import org.uqbar.project.wollok.typesystem.constraints.typeRegistry.MethodTypeProvider

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariableOwner.getURI

class TypeVariablesRegistry {
	val Map<URI, TypeVariable> typeVariables = newHashMap
	val Map<URI, ITypeVariable> typeSchemas = newHashMap
	val Logger log = Logger.getLogger(this.class)
	

	@Accessors(PUBLIC_GETTER)
	ConstraintBasedTypeSystem typeSystem

	@Accessors
	AnnotatedTypeRegistry annotatedTypes

	@Accessors(PUBLIC_GETTER)
	val methodTypes = new MethodTypeProvider(this)

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
	}

	def register(TypeVariable it) {
		// Only register variables which have an owner. Variables without an owner have are "synthetic", i.e. 
		// they have no representation in code. Proper handling of synthetic variables is yet to be polished
		if (owner !== null) typeVariables.put(owner.URI, it)
		return it
	}

	def register(TypeVariableSchema it) {
		// Only register variables which have an owner. Variables without an owner have are "synthetic", i.e. 
		// they have no representation in code. Proper handling of synthetic variables is yet to be polished
		it.registry = this 
		if (owner !== null) typeSchemas.put(owner.URI, it)
		return it
	}
	
	// ************************************************************************
	// ** Creating type variables.
	// ************************************************************************
	
	def asOwner(EObject programElement) {
		new ProgramElementTypeVariableOwner(programElement)
	}

	def newTypeVariable(EObject programElement) {
		programElement.asOwner.newTypeVariable
	}

	def newTypeVariable(TypeVariableOwner owner) {
		TypeVariable.simple(owner).register
	}

	def newVoid(TypeVariableOwner owner) {
		TypeVariable.newVoid(owner).register
	}

	def newParameter(TypeVariableOwner parent, String paramName) {
		new TypeVariable(new ParameterTypeVariableOwner(parent, paramName))
	}

	def newSealed(TypeVariableOwner it, WollokType type) {
		newTypeVariable => [beSealed(type)]
	}

	def beVoid(EObject it) {
		it.tvar.beVoid
	}

	def beSealed(EObject it, WollokType type) {
		tvar => [beSealed(type)]
	}

	def beSealed(TypeVariable it, WollokType type) {
		addMinType(type.instanceFor(it))
		beSealed
	}
	
	// ************************************************************************
	// ** Synthetic type variables
	// ************************************************************************

	def newClassParameterVar(TypeVariableOwner owner, GenericType type, String paramName) {
		TypeVariable.classParameter(owner, type, paramName) => [register]
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
			typeSchemas.get(obj.URI) => [ if (it === null) {
				throw new TypeSystemException("Missing type information for " + obj.debugInfoInContext)
			}]
	}
	
	def type(EObject obj) {
		typeVariables.get(obj.URI)?.type
	}

	// ************************************************************************
	// ** Error handling & debugging
	// ************************************************************************

	def addFatalError(EObject it, Exception exception) {
		val tvar = typeVariables.get(URI)
		if (tvar !== null) tvar.addFatalError(exception)
		else {
			val message = '''Fatal type system error working with «debugInfoInContext»: «exception.message ?: exception.class.simpleName»'''
			log.fatal(message, exception)
		}
		
		
	}	
		
	def addFatalError(TypeVariable variable, Exception exception) {
		val message = '''Fatal type system error: «exception.message ?: exception.class.simpleName»'''
		
		log.fatal(message, exception)
		
		variable.addError(new TypeSystemException(message) => [ it.variable = variable ])
	}
	
	def fullReport() {
		typeVariables.values.forEach[
			if (!owner.isCoreObject) log.debug(descriptionForReport)
		]
	}
	
}
