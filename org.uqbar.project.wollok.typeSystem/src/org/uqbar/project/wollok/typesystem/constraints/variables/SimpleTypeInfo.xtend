package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import org.eclipse.xtend.lib.annotations.AccessorType
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.eclipse.xtend.lib.annotations.AccessorType.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeStateExtensions.*

class SimpleTypeInfo extends TypeInfo {
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

	override beSealed() {
		maximalConcreteTypes = new MaximalConcreteTypes(minimalConcreteTypes.keySet)
		sealed = true
	}

	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
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
	override joinMaxTypes(MaximalConcreteTypes other) {
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

	override addMinimalType(WollokType type) {
		if (minimalConcreteTypes.containsKey(type))
			Ready
		else {
			(if (sealed) Error else Pending) => [
				minimalConcreteTypes.put(type, it)
			]
		}
	}

	override getType(TypeVariable tvar) {
		if (minimalConcreteTypes.size == 1) {
			minimalConcreteTypes.keySet.iterator.next
		} else {
			throw new TypeSystemException("Cannot determine a single type for " + tvar.fullDescription)
		}
	}
	
	override hasErrors() {
		minimalConcreteTypes.values.contains(Error)
	}
}
