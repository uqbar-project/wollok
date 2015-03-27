package org.uqbar.project.wollok.typesystem.constraints

import java.util.Map
import org.eclipse.xtend.lib.Property
import org.uqbar.project.wollok.semantics.TypeSystemException
import org.uqbar.project.wollok.semantics.WollokType

class TypeVariable {
	enum ConcreteTypeState {
		Pending,
		Ready
	}

	Map<WollokType, ConcreteTypeState> minimalConcreteTypes = newHashMap()

	// <Dictionary(CBConcreteType -> CBTypeAssociation)>
	//	maxConcreteTypes:	<Collection<Class>>
	//	name:		<String>
	//	subtypes:		<Set>
	//	supertypes:	<Set>
	//	messages:		<Dictionary(Symbol -> CBMessageSend)>	
	@Property var Boolean sealed = false

	// ************************************************************************
	// ** For the TypeSystem implementation
	// ************************************************************************

	def type() {
		if (minimalConcreteTypes.size == 1) {
			minimalConcreteTypes.keySet.iterator.next
		}
		else {
			throw new TypeSystemException("Cannot determine the type of an expression")
		}
	}

	// ************************************************************************
	// ** as yet unclassified
	// ************************************************************************
	def addMinimalType(WollokType type) {
		minimalConcreteTypes.put(type, ConcreteTypeState.Pending)
	}
}

class TypeVariablesFactory {
	static def sealed(WollokType type) {
		new TypeVariable => [
			addMinimalType(type)
			sealed = true
		]
	}
}
