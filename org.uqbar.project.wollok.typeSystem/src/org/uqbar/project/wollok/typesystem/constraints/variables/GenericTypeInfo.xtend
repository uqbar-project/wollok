package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.Map
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.types.UserFriendlySupertype
import org.uqbar.project.wollok.typesystem.exceptions.MessageNotUnderstoodException
import org.uqbar.project.wollok.typesystem.exceptions.RejectedMinTypeException

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.SubtypingRules.isSuperTypeOf
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.AnalysisResultReporter.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeStateExtensions.*

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
		basicGetType(tvar) ?: WollokType.WAny
	}

	def basicGetType(TypeVariable tvar) {
		var types = if(maximalConcreteTypes !== null)
				maximalConcreteTypes.maximalConcreteTypes
			else
				minTypes.keySet

		new UserFriendlySupertype(tvar).commonSupertype(
			types,
			messages
		)
	}

	// ************************************************************************
	// ** Type parameters
	// ************************************************************************
	def param(GenericType type, String paramName) {
		val typeInstance = findCompatibleTypeFor(type)
		if(typeInstance === null)
			throw new IllegalStateException(
				NLS.bind(Messages.RuntimeTypeSystemException_CANT_FIND_MIN_TYPE, #[type, paramName, minTypes.keySet]))

		typeInstance.findParam(paramName)
	}

	def findCompatibleTypeFor(GenericType type) {
		minTypes.keySet.findFirst[type.baseType.isSuperTypeOf(it)]
	}

	def dispatch findParam(GenericTypeInstance typeInstance, String paramName) {
		typeInstance.param(paramName)
	}

	def dispatch findParam(WollokType type, String paramName) {
		throw new IllegalArgumentException(
			NLS.bind(Messages.RuntimeTypeSystemException_GENERIC_TYPE_EXPECTED, type, type.class))
	}

	// ************************************************************************
	// ** Adding type information
	// ************************************************************************
	override beSealed() {
		if (maximalConcreteTypes === null) 
			maximalConcreteTypes = new MaximalConcreteTypes(minTypes.keySet)
		else if (!minTypes.empty)
			maximalConcreteTypes.restrictTo(new MaximalConcreteTypes(minTypes.keySet))
		super.beSealed
	}

	override setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable offender) {
		minTypes.statesDo(offender) [
			if(!offender.hasErrors(type)) {
				val matchingMaxType = maxTypes.findMatching(type)
				if(matchingMaxType !== null) {
					type.beSubtypeOf(matchingMaxType)
				} else {
					error(new RejectedMinTypeException(offender, type, maxTypes.maximalConcreteTypes))
					maxTypes.state = Error
				}
			}
		]

		if(maxTypes.state == Error) {
			false
		} else if(maximalConcreteTypes === null) {
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
		if(maximalConcreteTypes !== null) {
			if(other !== null) {
				if(maximalConcreteTypes != other.maximalConcreteTypes) {
					maximalConcreteTypes.restrictTo(other)
					maximalConcreteTypes.state = Pending
				} else {
					maximalConcreteTypes.state = maximalConcreteTypes.state.join(other.state)
				}
			} else {
				maximalConcreteTypes.state = Pending
			}
		} else if(other !== null) {
			maximalConcreteTypes = other.copy
		}
	}

	override ConcreteTypeState addMinType(WollokType type, TypeVariable offender) {
		if(minTypes.containsKey(type)) return Ready

		try {
			validateType(type, offender)
			minTypes.put(type, Pending)
			Pending
		} catch(TypeSystemException exception) {
			minTypes.put(type, Error)
			throw exception
		}
	}

	def validateType(WollokType type, TypeVariable offender) {
		if(sealed && !minTypes.isEmpty && !minTypes.keySet.exists[isSuperTypeOf(type)]) {
			throw new RejectedMinTypeException(offender, type, maximalConcreteTypes.maximalConcreteTypes)
		}

		validMessages.forEach [
			if(!type.respondsTo(it, false)) 
				throw new MessageNotUnderstoodException(type, it)
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
		if(parameterCount > 0) (0 .. parameterCount - 1).map[PARAM] else #[]
	}

	// ************************************************************************
	// ** Misc
	// ************************************************************************
	override toString() '''
		«class.simpleName» of «canonicalUser»: «typeDescriptionForDebug»
	'''

	override typeDescriptionForDebug() {
		basicGetType(canonicalUser)?.toString ?: "unknown"
	}

	override fullDescription() '''
		sealed: «sealed»,
		minTypes: «minTypes»,
		maxTypes: «maximalConcreteTypes?:"unknown"»
		messages: «messages»
	'''
}
