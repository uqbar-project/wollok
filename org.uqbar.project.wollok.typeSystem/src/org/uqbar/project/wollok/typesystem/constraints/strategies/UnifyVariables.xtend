package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.Set
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ClosureTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WParameter

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

/**
 * TODO: Maybe this strategy goes a bit to far unifying variables and we should review it at some point in the future. 
 * Specially, for method parameters, we should take care of prioritizing internal uses over any information from outside the method.
 */
class UnifyVariables extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		println('''Analising unification of «tvar» «tvar.subtypes.size», «tvar.supertypes.size»''')
		if (tvar.subtypes.size == 1)
			tvar.subtypes.uniqueElement.unifyWith(tvar)
		if (tvar.supertypes.size == 1)
			tvar.unifyWith(tvar.supertypes.uniqueElement)
	}

	def unifyWith(TypeVariable subtype, TypeVariable supertype) {
		println('''About to unify «subtype» with «supertype»''')
		if (subtype.unifiedWith(supertype)) {
			println('''Already unified, nothing to do''')
			return;
		}
		
		// We can only unify in absence of errors, this aims for avoiding error propagation 
		// and further analysis of the (maybe) correct parts of the program.
		if (supertype.hasErrors) {
			println('''Errors found, aborting unification''')
			return;
		}
		
		// If supertype var is a parameter, the subtype is an argument sent to this parameter
		// and should not be unified.
		if (supertype.owner instanceof WParameter) {
			println('''Not unifying «subtype» with parameter «supertype»''')
			return;
		}

		// Now we can unify
		println('''	Unifying «subtype» with «supertype»''')
		
		// We are not handling unification of two variables with no type info, yet it should not be a problem because there is no information to share.
		// Since we are doing nothing, eventually when one of the variables has some type information, unification will be done. 
		if (subtype.typeInfo == null && supertype.typeInfo != null) {
			subtype.typeInfo = supertype.typeInfo
			changed = true
		} else if (supertype.typeInfo == null && subtype.typeInfo != null) {
			supertype.typeInfo = subtype.typeInfo
			changed = true
		} else {
			subtype.typeInfo.doUnifyWith(supertype.typeInfo)
		}
	}

	def dispatch doUnifyWith(SimpleTypeInfo t1, SimpleTypeInfo t2) {
		t1.minimalConcreteTypes = minTypesUnion(t1, t2)
		t1.joinMaxTypes(t2.maximalConcreteTypes)

		t2.users.forEach[typeInfo = t1]

		changed = true
	}

	def dispatch doUnifyWith(ClosureTypeInfo t1, ClosureTypeInfo t2) {
		throw new UnsupportedOperationException()
	}

	protected def minTypesUnion(SimpleTypeInfo t1, SimpleTypeInfo t2) {
		(t1.minimalConcreteTypes.keySet + t2.minimalConcreteTypes.keySet).toSet.toInvertedMap [
			if (isReadyIn(t1) && isReadyIn(t2))
				// It was already present and ready in both originating typeInfo's
				Ready
			else
				// Mark this concrete type to be further propagated.
				Pending
		]
	}

	/**
	 * Verify if the received type is already present as a mintype in the variable
	 * and if its Ready (i.e. type information has already been propagated.
	 */
	def boolean isReadyIn(WollokType wollokType, SimpleTypeInfo type) {
		type.minimalConcreteTypes.get(wollokType) == Ready
	}

	def <T> T uniqueElement(Set<T> it) { iterator.next }

}
