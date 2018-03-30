package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import java.util.function.Consumer
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.exceptions.RejectedMinTypeException

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.SubtypingRules.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.UserFriendlySupertype.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeStateExtensions.*

class GenericTypeInfo extends TypeInfo {
	@Accessors
	var Map<WollokType, ConcreteTypeState> minTypes = newHashMap()

	@Accessors(PUBLIC_GETTER)
	var MaximalConcreteTypes maximalConcreteTypes = null

	@Accessors
	Map<String, TypeVariable> params

	new() {
		this(newHashMap)
	}
	
	new(Map<String, TypeVariable> params) {
		this.params = params
	}

	// ************************************************************************
	// ** Queries & Accessing
	// ************************************************************************
	override getType(TypeVariable tvar) {
		// Imposibility to find a unique type now are reported as WAny, this has to be improved
		basicGetType() ?: WollokType.WAny
	}

	def basicGetType() {
		minTypes.entrySet
			//.filter[value != Error]
			.map[key]
			.commonSupertype(messages)
	}

	def param(String paramName) {
		params.get(paramName)
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
			true
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
		} else if (!canAddMinType(type)) {
			throw new RejectedMinTypeException(type)
		} else {
			minTypes.put(type, Pending)
			Pending
		}
	}

	def canAddMinType(WollokType type) {
		if (sealed) minTypes.keySet.exists[isSuperTypeOf(type)]
		else type.respondsToAll(messages)
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
	// ** Utilities for generic types
	// ************************************************************************

	/**
	 * Default type parameter for collection types
	 */
	public static val KEY = "key"
	public static val VALUE = "value"
	public static val ELEMENT = "element"

	static def TypeVariable element(TypeVariable user) {
		(user.typeInfo as GenericTypeInfo).param(ELEMENT)
	}

	// ************************************************************************
	// ** Misc
	// ************************************************************************
	override fullDescription() '''
		«IF !params.isEmpty»
		generic(«params.keySet»)
		«ENDIF»
		sealed: «sealed»,
		minTypes: «minTypes»,
		maxTypes: «maximalConcreteTypes?:"unknown"»
		messages: «messages»
	'''
}
