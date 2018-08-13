package org.uqbar.project.wollok.typesystem.constraints.variables

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

	new(Iterable<? extends WollokType> types) {
		maximalConcreteTypes = newHashSet(types)
	}

	// ************************************************************************
	// ** Querying
	// ************************************************************************
	def contains(WollokType type) {
		maximalConcreteTypes.exists[isSuperTypeOf(type)]
	}

	def WollokType findMatching(WollokType type) {
		maximalConcreteTypes.findFirst[isSuperTypeOf(type)]
	}
	

	def containsAll(Iterable<? extends WollokType> types) {
		types.forall[this.contains(it)]
	}

	def copy() {
		new MaximalConcreteTypes(maximalConcreteTypes)
	}
	
	def empty() {
		maximalConcreteTypes.empty
	}

	// ************************************************************************
	// ** Restricting
	// ************************************************************************
	def restrictTo(MaximalConcreteTypes supertype) {
		val originalSize = maximalConcreteTypes.size

		maximalConcreteTypes.removeIf[!supertype.contains(it)]

		val changed = maximalConcreteTypes.size < originalSize
		if (changed) state = Pending
		return changed
	}

	// ************************************************************************
	// ** Utilities
	// ************************************************************************
	def forEach((WollokType)=>void action) {
		maximalConcreteTypes.forEach(action)
	}

	override toString() '''max(«maximalConcreteTypes») [«state»]'''
	
}

