package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import java.util.function.Consumer
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.exceptions.RejectedMinTypeException

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.SubtypingRules.isSuperTypeOf
import static extension org.uqbar.project.wollok.typesystem.constraints.types.UserFriendlySupertype.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeStateExtensions.*
import org.uqbar.project.wollok.typesystem.exceptions.MessageNotUnderstoodException

class GenericTypeInfo extends TypeInfo {
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
		minTypes.entrySet// .filter[value != Error]
		.map[key].commonSupertype(messages)
	}

	// ************************************************************************
	// ** Type parameters
	// ************************************************************************
	def param(GenericType type, String paramName) {
		val typeInstance = findCompatibleTypeFor(type)
		if (typeInstance === null)
			throw new IllegalStateException('''Can't find a minType compatible with «type».«paramName», known minTypes are «minTypes.keySet»''')

		typeInstance.findParam(paramName)
	}

	def findCompatibleTypeFor(GenericType type) {
		minTypes.keySet.findFirst[type.isSuperTypeOf(it)]
	}

	def dispatch findParam(GenericTypeInstance typeInstance, String paramName) {
		typeInstance.param(paramName)
	}

	def dispatch findParam(WollokType type, String paramName) {
		throw new IllegalArgumentException('''Expecting a generic type but found «type» of type «type.class».''')
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
	def minTypesDo(TypeVariable origin, Consumer<AnalysisResultReporter<WollokType>> action) {
		val reporter = new AnalysisResultReporter(origin)
		minTypes.entrySet.forEach [
			reporter.currentEntry = it
			action.accept(reporter)
		]
	}

	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable origin) {
		minTypesDo(origin) [
			if (!origin.hasErrors(type) && !maxTypes.contains(type))
				error(new RejectedMinTypeException(origin, type, maxTypes.maximalConcreteTypes))
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

	override ConcreteTypeState addMinType(WollokType type, TypeVariable origin) {
		if(minTypes.containsKey(type)) return Ready

		validateNewMinType(type, origin)

		minTypes.put(type, Pending)
		Pending

	}

	def validateNewMinType(WollokType type, TypeVariable origin) {
		if (sealed && !minTypes.keySet.exists[isSuperTypeOf(type)]) {
			throw new RejectedMinTypeException(origin, type, minTypes.keySet)
		}

		validMessages.forEach [
			if(!type.respondsTo(it)) throw new MessageNotUnderstoodException(type, it)
		]

	}

	def unifyWith(WollokType existing, WollokType added) {
		// Nothing to do (?)
	}

	def unifyWith(GenericTypeInstance existing, GenericTypeInstance added) {
		existing.typeParameters.forEach [ name, param |
			// This makes all type parameters invariant, co- and contra-variance needs further work.
			param.beSubtypeOf(added.param(name))
			param.beSupertypeOf(added.param(name))
		]
	}

	// ************************************************************************
	// ** Notifications
	// ************************************************************************
	/**
	 * This collaborates with the maxType propagation, 
	 * resetting maxTypes state to force them to be propagated to the new subtypes.
	 */
	override subtypeAdded(TypeVariable subtype) {
		maximalConcreteTypes => [
			if(it !== null) state = state.join(Pending)
		]
	}

	/**
	 * This collaborates with the maxType propagation, 
	 * resetting maxTypes state to force them to be propagated to the new subtypes.
	 */
	override supertypeAdded(TypeVariable supertype) {
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
	public static val RETURN = "return"
	public static def PARAM(int position) { "arg" + position }
	public static def PARAMS(int parameterCount) {
		if (parameterCount > 0) (0 .. parameterCount - 1).map[PARAM] else #[]
	}


	// ************************************************************************
	// ** Misc
	// ************************************************************************
	
	override toString() '''
	 	«class.simpleName» of «this.canonicalUser»: «basicGetType()?.toString ?: "unknown"»
	'''
	
	override fullDescription() '''
		sealed: «sealed»,
		minTypes: «minTypes»,
		maxTypes: «maximalConcreteTypes?:"unknown"»
		messages: «messages»
	'''
}
