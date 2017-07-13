package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.types.SubtypingRules.*

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
		maximalConcreteTypes.exists[isSuperTypeOf(type)]
	}

	def containsAll(List<? extends WollokType> types) {
		types.forall[this.contains(it)]
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

