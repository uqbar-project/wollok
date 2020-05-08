package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.Set
import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.ITypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeStateExtensions.*
import org.uqbar.project.wollok.typesystem.exceptions.CannotBeVoidException

/**
 * @author npasserini
 */
class UnifyVariables extends AbstractInferenceStrategy {
	Set<TypeVariable> alreadySeen = newHashSet
	val Logger log = Logger.getLogger(this.class)

	override analiseVariable(TypeVariable tvar) {
		if(!alreadySeen.contains(tvar)) {
			var result = Ready

			if(tvar.subtypes.size == 1) {
				result = tvar.subtypes.uniqueElement.unifyWith(tvar)
			}
			if(tvar.supertypes.size == 1) {
				result = result.join(tvar.unifyWith(tvar.supertypes.uniqueElement))
			}

			if(result != Pending) alreadySeen.add(tvar)
		}
	}

	/**
	 * @return ConcreteTypeState
	 * - Ready means this variable has been unified and needs no further analysis.
	 * - Cancel means this variable has not unified and needs not further analysis.
	 * - Pending means this variable needs to be visited again.
	 * - Error means a type error was detected, variable will not be visited again.
	 */
	def ConcreteTypeState unifyWith(ITypeVariable subtype, ITypeVariable supertype) {
		unifyWith(subtype as TypeVariable, supertype as TypeVariable)
	}

	def ConcreteTypeState unifyWith(TypeVariable subtype, TypeVariable supertype) {
		if(subtype.unifiedWith(supertype)) {
			return Ready
		}

		// Do not unify with core library elements
		if(subtype.owner.isCoreObject || supertype.owner.isCoreObject) {
			return Cancel
		}

		// We can only unify in absence of errors, this aims for avoiding error propagation 
		// and further analysis of the (maybe) correct parts of the program.
		if(subtype.hasErrors || supertype.hasErrors) {
			log.debug('''Unifying «subtype» with «supertype»: errors found, aborting unification''')
			return Error
		}

		// Now we can unify
		subtype.doUnifyWith(supertype) => [
			if(it != Pending && it != Cancel)
				log.debug('''«it» | Unified «subtype» with «supertype» : «subtype.typeInfo?.typeDescriptionForDebug»''')
		]
	}

	def dispatch ConcreteTypeState doUnifyWith(TypeVariable subtype, TypeVariable supertype) {
		// We are not handling unification of two variables with no type info, yet it should not be a problem because there is no information to share.
		// Since we are doing nothing, eventually when one of the variables has some type information, unification will be done. 
		if(subtype.typeInfo === null && supertype.typeInfo === null) {
			log.debug('''Unifying «subtype» with «supertype»: no type info yet, unification postponed''')
			Pending
		} else if(subtype.typeInfo === null) {
			subtype.copyTypeInfoFrom(supertype)
		} else if(supertype.typeInfo === null) {
			supertype.copyTypeInfoFrom(subtype)
		} else if(biUniqueRelationship(subtype, supertype) // Unify if both variables are uniques subtype/supertypes respectively
		|| supertype.isVariableReferenceTo(subtype) // Unify variable references with their associated referenciables.
		|| subtype.typeInfo.isEmpty || subtype.typeInfo.isEmpty) {
			subtype.typeInfo.doUnifyWith(supertype.typeInfo)
		} else {
			Cancel
		}
	}

	def dispatch isEmpty(VoidTypeInfo it) { true }
	def dispatch isEmpty(GenericTypeInfo it) { minTypes.isEmpty && maximalConcreteTypes === null }

	def dispatch hasPostponedMinType(VoidTypeInfo it) { false }
	def dispatch hasPostponedMinType(GenericTypeInfo it) { minTypes.values.contains(Postponed)}

	// ************************************************************************
	// ** Unification conditions
	// ************************************************************************
	def isVariableReferenceTo(TypeVariable supertype, TypeVariable subtype) {
		supertype.owner.isReferenceTo(subtype.owner)
	}

	def biUniqueRelationship(TypeVariable subtype, TypeVariable supertype) {
		subtype.supertypes.size == 1 && supertype.subtypes.size == 1
	}

	// ************************************************************************
	// ** Proper unification
	// ************************************************************************
	def copyTypeInfoFrom(TypeVariable v1, TypeVariable v2) {
		try {
			v1.typeInfo = v2.typeInfo
			changed = true
			Ready
		} catch(TypeSystemException typeError) {
			v2.addError(typeError)
			Error
		}
	}
	
	def dispatch doUnifyWith(GenericTypeInfo t1, GenericTypeInfo t2) {		
		t1.minTypes = minTypesUnion(t1, t2)
		t1.joinMaxTypes(t2.maximalConcreteTypes)
		t1.messages.addAll(t2.messages)


		t2.users.forEach[typeInfo = t1]

		changed = true
		Ready
	}

	def dispatch doUnifyWith(VoidTypeInfo t1, VoidTypeInfo t2) {
		// Nothing to do
		Ready
	}
	
	def dispatch doUnifyWith(GenericTypeInfo t1, VoidTypeInfo t2) {
		t1.users.forEach[canNotBeVoid]
		Error
	}

	def dispatch doUnifyWith(VoidTypeInfo t1, GenericTypeInfo t2) {
		t2.users.forEach[canNotBeVoid]
		Error
	}
	
	def canNotBeVoid(TypeVariable it) {
		addError(new CannotBeVoidException(it.owner.errorReportTarget))	
	}
	
	protected def minTypesUnion(GenericTypeInfo t1, GenericTypeInfo t2) {
		(t1.minTypes.keySet + t2.minTypes.keySet).toSet.toInvertedMap [
			if(isReadyIn(t1) && isReadyIn(t2))
				// It was already present and ready in both originating typeInfo's
				Ready
			else if (isPostponedIn(t1) || isPostponedIn(t2))
				Postponed
			else
				// Mark this concrete type to be further propagated.
				Pending
		]
	}

	/**
	 * Verify if the received type is already present as a mintype in the variable
	 * and if its Ready (i.e. type information has already been propagated.
	 */
	def boolean isReadyIn(WollokType wollokType, GenericTypeInfo type) {
		wollokType.isStateIn(type, Ready)
	}
	
	def boolean isPostponedIn(WollokType wollokType, GenericTypeInfo type) {
		wollokType.isStateIn(type, Postponed)
	}

	def boolean isStateIn(WollokType wollokType, GenericTypeInfo type, ConcreteTypeState state) {
		type.minTypes.get(wollokType) == state
	}
	
	def <T> T uniqueElement(Set<T> it) { iterator.next }

}
