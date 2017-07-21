package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import java.util.function.Consumer
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.exceptions.RejectedMinTypeException

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.types.SubtypingRules.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeStateExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*

class SimpleTypeInfo extends TypeInfo {
	@Accessors
	var Map<WollokType, ConcreteTypeState> minTypes = newHashMap()

	@Accessors(PUBLIC_GETTER)
	var MaximalConcreteTypes maximalConcreteTypes = null

	// ************************************************************************
	// ** Queries
	// ************************************************************************
	override getType(TypeVariable tvar) {
		// Imposibility to find a unique type now are reported as WAny, this has to be improved
		basicGetType() ?: WollokType.WAny
	}

	def basicGetType() {
		minTypes.entrySet.filter[value != Error].map[key].reduce[t1, t2|t1.refine(t2)]
	}

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	override beSealed() {
		maximalConcreteTypes = new MaximalConcreteTypes(minTypes.keySet)
		super.beSealed
	}

	/**
	 * Execute an action for each known minType, updating its state according to action result 
	 * and reporting errors to the origin type variable.
	 */
	def minTypesDo(TypeVariable origin, Consumer<MinTypeAnalysisResultReporter> action) {
		val reporter = new MinTypeAnalysisResultReporter(origin)
		minTypes.entrySet.forEach [
			reporter.currentEntry = it
			action.accept(reporter)
		]
	}

	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable origin) {
		minTypesDo(origin) [
			if (!maxTypes.contains(type))
				error(new RejectedMinTypeException(origin, type))
		]

		if (maximalConcreteTypes === null) {
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
		if (maximalConcreteTypes !== null) {
			if (other !== null) {
				if (maximalConcreteTypes != other.maximalConcreteTypes) {
					maximalConcreteTypes.restrictTo(other)
					maximalConcreteTypes.state = Pending
				} else {
					maximalConcreteTypes.state = maximalConcreteTypes.state.join(other.state)
				}
			} else {
				maximalConcreteTypes.state = Pending
			}
		} else if (other !== null) {
			maximalConcreteTypes = other.copy
		}
	}

	override ConcreteTypeState addMinType(WollokType type) {
		if (minTypes.containsKey(type)) {
			Ready
		} else if (canAddMinType(type)) {
			throw new RejectedMinTypeException(type)
		} else {
			minTypes.put(type, Pending)
			Pending
		}
	}

	def canAddMinType(WollokType type) {
		messages.forEach[msg| (type as AbstractContainerWollokType).respondsTo(msg)]
		(sealed && !minTypes.keySet.exists[isSuperTypeOf(type)])
	}
	
	// ************************************************************************
	// ** Notifications
	// ************************************************************************
	/**
	 * This collaborates with the maxType propagation, 
	 * resetting maxTypes state to force them to be propagated to the new subtypes.
	 */
	override subtypeAdded() {
		maximalConcreteTypes => [
			if (it !== null) state = state.join(Pending)
		]
	}

	/**
	 * This collaborates with the maxType propagation, 
	 * resetting maxTypes state to force them to be propagated to the new subtypes.
	 */
	override supertypeAdded() {
		minTypes.entrySet.forEach[value = value.join(Pending)]
	}

	// ************************************************************************
	// ** Misc
	// ************************************************************************
	override fullDescription() '''
		sealed: «sealed»,
		minTypes: «minTypes»,
		maxTypes: «maximalConcreteTypes?:"unknown"»
		messages: «messages»
	'''
}
