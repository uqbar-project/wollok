package org.uqbar.project.wollok.typesystem.constraints

import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.AccessorType
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

import static org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeState.*

import static extension org.eclipse.xtend.lib.annotations.AccessorType.*
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokTypeSystemPrettyPrinter.*
import static extension org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeStateExtensions.*

import java.util.List

class TypeVariable {
	@Accessors
	val EObject owner

	@Accessors
	var TypeInfo typeInfo = new TypeInfo(this)

	@Accessors
	val Set<TypeVariable> subtypes = newHashSet

	@Accessors
	val Set<TypeVariable> supertypes = newHashSet

	new(EObject owner) {
		this.owner = owner
	}

	// ************************************************************************
	// ** For the TypeSystem implementation
	// ************************************************************************
	def getType() {
		if (typeInfo.minimalConcreteTypes.size == 1) {
			typeInfo.minimalConcreteTypes.keySet.iterator.next
		} else {
			throw new TypeSystemException("Cannot determine a single type for " + fullDescription)
		}
	}

	// ************************************************************************
	// ** Errors
	// ************************************************************************
	def hasErrors() {
		typeInfo.minimalConcreteTypes.values.contains(Error)
	}

	def reportErrors(ConfigurableDslValidator validator) {
		if (hasErrors)
			validator.report('''expected <<«expectedType»>> but found <<«foundType»>>''', owner)
	}

	// ************************************************************************
	// ** Adding constraints
	// ************************************************************************
	def beSupertypeOf(TypeVariable subtype) {
		this.subtypes.add(subtype)
		subtype.supertypes.add(this)
	}

	def beSubtypeOf(TypeVariable supertype) {
		this.supertypes.add(supertype)
		supertype.subtypes.add(this)
	}

	// ************************************************************************
	// ** Adding / accessing type info
	// ************************************************************************
	def setTypeInfo(TypeInfo newTypeInfo) {
		newTypeInfo.users.add(this)
		this.typeInfo = newTypeInfo
	}

	def getMinimalConcreteTypes() { typeInfo.minimalConcreteTypes }

	def addMinimalType(WollokType type) { typeInfo.addMinimalType(type) }

	def getMaximalConcreteTypes() { typeInfo.maximalConcreteTypes }

	def setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		typeInfo.maximalConcreteTypes = maxTypes
	}

	def isSealed() { typeInfo.sealed }

	def beSealed() { typeInfo.beSealed() }

	// ************************************************************************
	// ** Unification information
	// ************************************************************************

	def unifiedWith(TypeVariable other) {
		this.typeInfo == other.typeInfo
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	override def toString() '''t(«owner.debugInfo»)'''

	def fullDescription() '''
		«class.simpleName» {
			owner: «owner.debugInfo»,
			subtypes: «subtypes.map[owner.debugInfo]»,
			supertypes: «supertypes.map[owner.debugInfo]»,
			«IF typeInfo.users.get(0) == this»
				sealed: «sealed»,
				minTypes: «minimalConcreteTypes»,
				maxTypes: «maximalConcreteTypes?:"unknown"»
			«ELSE»
				... unified with «typeInfo.users.get(0)»
			«ENDIF»
		}
	'''
}

class MaximalConcreteTypes {
	@Accessors
	val Set<WollokType> maximalConcreteTypes

	@Accessors
	var ConcreteTypeState state = Pending

	new(Set<WollokType> types) {
		maximalConcreteTypes = newHashSet(types)
	}

	// ************************************************************************
	// ** Querying
	// ************************************************************************

	def contains(WollokType type) {
		maximalConcreteTypes.contains(type)
	}

	def copy() {
		new MaximalConcreteTypes(maximalConcreteTypes)
	}

	// ************************************************************************
	// ** Restricting
	// ************************************************************************

	def restrictTo(MaximalConcreteTypes supertype) {
		val originalSize = maximalConcreteTypes.size

		maximalConcreteTypes.removeIf[!supertype.contains(it)]

		if (maximalConcreteTypes.size < originalSize)
			state = Pending
	}

	// ************************************************************************
	// ** Utilities
	// ************************************************************************
	
	def forEach((WollokType)=>void action) {
		maximalConcreteTypes.forEach(action)
	}

	override toString() '''max(«maximalConcreteTypes») [«state»]'''
	
}

class TypeInfo {
	@Accessors
	val List<TypeVariable> users = newArrayList

	// messages:		<Dictionary(Symbol -> CBMessageSend)>	
	@Accessors
	var Map<WollokType, ConcreteTypeState> minimalConcreteTypes = newHashMap()

	@Accessors
	var MaximalConcreteTypes maximalConcreteTypes = null

	/**
	 * A sealed variable can not be further restricted. 
	 * Minimal and maximal concrete type sets should be equal after sealing a variable. 
	 */
	@Accessors(AccessorType.PUBLIC_GETTER)
	var Boolean sealed = false

	new(TypeVariable variable) {
		users.add(variable)
	}

	def beSealed() {
		maximalConcreteTypes = new MaximalConcreteTypes(minimalConcreteTypes.keySet)
		sealed = true
	}

	def setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		minimalConcreteTypes.entrySet.forEach [ it |
			if (!maxTypes.contains(key)) value = Error
		]

		if (maximalConcreteTypes == null) {
			maximalConcreteTypes = maxTypes.copy
		} else {
			maximalConcreteTypes.restrictTo(maxTypes)
		}
	}

	/** 
	 * Join maxtype information coming from two different tvar's. Null information has to be taken care from both sides, 
	 * and new state has to be pending if there is any information that is new to any of the original tvar's (so unless
	 * both original sets were equal, state has to be Pending).  
	 */
	def joinMaxTypes(MaximalConcreteTypes other) {
		if (maximalConcreteTypes != null) {
			if (other != null) {
				if (maximalConcreteTypes != other.maximalConcreteTypes) {
					maximalConcreteTypes.restrictTo(other)
					maximalConcreteTypes.state = Pending
				} else {
					maximalConcreteTypes.state = maximalConcreteTypes.state.join(other.state)
				}
			} else {
				maximalConcreteTypes.state = Pending
			}
		} else if (other != null) {
			maximalConcreteTypes = other.copy
		}
	}

	def addMinimalType(WollokType type) {
		if (minimalConcreteTypes.containsKey(type))
			Ready
		else {
			(if (sealed) Error else Pending) => [
				minimalConcreteTypes.put(type, it)
			]
		}
	}
}
