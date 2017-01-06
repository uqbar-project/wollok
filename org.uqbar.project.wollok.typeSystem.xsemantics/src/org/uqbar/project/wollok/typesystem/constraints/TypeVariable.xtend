package org.uqbar.project.wollok.typesystem.constraints

import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.AccessorType
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable.ConcreteTypeState

import static extension org.eclipse.xtend.lib.annotations.AccessorType.*
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo

class TypeVariable {
	enum ConcreteTypeState {
		Pending,
		Ready,
		Error
	}

	@Accessors
	val EObject owner

	@Accessors
	val Map<WollokType, ConcreteTypeState> minimalConcreteTypes = newHashMap()

	// <Dictionary(CBConcreteType -> CBTypeAssociation)>
	@Accessors(AccessorType.PUBLIC_GETTER)
	var MaximalConcreteTypes maximalConcreteTypes = null

	@Accessors
	val Set<TypeVariable> subtypes = newHashSet

	@Accessors
	val Set<TypeVariable> supertypes = newHashSet

	// messages:		<Dictionary(Symbol -> CBMessageSend)>	
	/**
	 * A sealed variable can not be further restricted. 
	 * Minimal and maximal concrete type sets should be equal after sealing a variable. 
	 */
	@Accessors(AccessorType.PUBLIC_GETTER)
	var Boolean sealed = false

	new(EObject owner) {
		this.owner = owner
	}

	// ************************************************************************
	// ** For the TypeSystem implementation
	// ************************************************************************

	def type() {
		if (minimalConcreteTypes.size == 1) {
			minimalConcreteTypes.keySet.iterator.next
		} else {
			throw new TypeSystemException("Cannot determine a single type for " + fullDescription)
		}
	}
	
	def hasErrors() {
		minimalConcreteTypes.values.contains(ConcreteTypeState.Error)
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

	def beSealed() {
		maximalConcreteTypes = new MaximalConcreteTypes(minimalConcreteTypes.keySet)
		sealed = true
	}

	// ************************************************************************
	// ** Internal information management
	// ************************************************************************
	
	def addMinimalType(WollokType type) {
		if (minimalConcreteTypes.containsKey(type)) 
			ConcreteTypeState.Ready
		else {
			(if (sealed) ConcreteTypeState.Error else ConcreteTypeState.Pending) => [
				minimalConcreteTypes.put(type, it)
			]
		}
	}

	def setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		minimalConcreteTypes.entrySet.forEach[it|
			if(!maxTypes.contains(key)) value = ConcreteTypeState.Error 
		]

		if (maximalConcreteTypes == null) {
			maximalConcreteTypes = maxTypes.copy
		}
		else {
			maximalConcreteTypes.restrictTo(maxTypes)			
		}
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************

	override def toString() '''t(«owner.debugInfo»)'''

	def fullDescription() '''
		«class.simpleName» {
			owner: «owner.debugInfo»,
			sealed: «sealed»,
			minTypes: «minimalConcreteTypes»,
			maxTypes: «maximalConcreteTypes?:"unknown"»,
			subtypes: «subtypes.map[owner.debugInfo]»,
			supertypes: «supertypes.map[owner.debugInfo]»
		}
	'''

}

class MaximalConcreteTypes {
	@Accessors
	val Set<WollokType> maximalConcreteTypes

	@Accessors
	var ConcreteTypeState state = ConcreteTypeState.Pending


	new(Set<WollokType> types) {
		maximalConcreteTypes = newHashSet(types)
	}

	def contains(WollokType type) {
		maximalConcreteTypes.contains(type)
	}

	def copy() {
		new MaximalConcreteTypes(maximalConcreteTypes)
	}
	
	def restrictTo(MaximalConcreteTypes supertype) {
		maximalConcreteTypes.removeIf[!supertype.contains(it)]
	}
	
	override toString() '''max(«maximalConcreteTypes») [«state»]'''
}
