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
import org.uqbar.project.wollok.typesystem.ConcreteType

class TypeVariable {
	enum ConcreteTypeState {
		Pending,
		Ready
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
	
	def fullDescription() '''
		«class.simpleName» {
			owner: «owner»,
			sealed: «sealed»,
			minTypes: «minimalConcreteTypes»,
			maxTypes: «maximalConcreteTypes?:"unknown"»,
			subtypes: «subtypes.map[owner]»,
			supertypes: «supertypes.map[owner]»
		}
	'''

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
		minimalConcreteTypes.put(type, ConcreteTypeState.Pending)
	}
	
	def setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		maximalConcreteTypes = new MaximalConcreteTypes(maxTypes.maximalConcreteTypes)
		if (sealed) {
			maximalConcreteTypes.maximalConcreteTypes.forEach[addMinimalType]
		}
	}
	
	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	
	override def toString() '''t(«owner»)'''
}

class MaximalConcreteTypes {
	@Accessors
	val Set<WollokType> maximalConcreteTypes
	
	@Accessors
	var ConcreteTypeState state = ConcreteTypeState.Pending	
	
	new(Set<WollokType> types) {
		maximalConcreteTypes = types
	}
	
	override toString() '''max(«maximalConcreteTypes») [«state»]'''
}