package org.uqbar.project.wollok.typesystem.constraints

import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType

class TypeVariable {
	enum ConcreteTypeState {
		Pending,
		Ready
	}

	EObject owner

	@Accessors
	val Map<WollokType, ConcreteTypeState> minimalConcreteTypes = newHashMap()

	// <Dictionary(CBConcreteType -> CBTypeAssociation)>
	// maxConcreteTypes:	<Collection<Class>>
	// name:		<String>
	
	@Accessors
	val Set<TypeVariable> subtypes = newHashSet
	
	@Accessors
	val Set<TypeVariable> supertypes = newHashSet

	// messages:		<Dictionary(Symbol -> CBMessageSend)>	
	@Accessors
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
			minTypes: «minimalConcreteTypes»
			subtypes: «subtypes.map[owner]»
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

	// ************************************************************************
	// ** Internal information management
	// ************************************************************************
	
	def addMinimalType(WollokType type) {
		minimalConcreteTypes.put(type, ConcreteTypeState.Pending)
	}
	
	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	
	override def toString() '''t(«owner»)'''
}