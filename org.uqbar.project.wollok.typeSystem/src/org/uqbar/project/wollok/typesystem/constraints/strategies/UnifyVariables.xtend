package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.Set
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.ClosureTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

/**
 * TODO: Maybe this strategy goes a bit to far unifying variables and we should review it at some point in the future. 
 * Specially, for method parameters, we should take care of prioritizing internal uses over any information from outside the method.
 */
class UnifyVariables extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		if (tvar.subtypes.size == 1)
			tvar.unifyWith(tvar.subtypes.uniqueElement)
		if (tvar.supertypes.size == 1)
			tvar.unifyWith(tvar.supertypes.uniqueElement)
	}

	def unifyWith(TypeVariable v1, TypeVariable v2) {
		// We can only unify in absence of errors, this aims for avoiding error propagation 
		// and further analysis of the (maybe) correct parts of the program.
		if (!v2.hasErrors && !v1.unifiedWith(v2)) {
			println('''	Unifying «v1» with «v2»''')

			// We are not handling unification of two variables with no type info, yet it should not be a problem because there is no information to share.
			// Since we are doing nothing, eventually when one of the variables has some type information, unification will be done. 
			if (v1.typeInfo == null && v2.typeInfo != null) {
				v1.typeInfo = v2.typeInfo
				changed = true
			} else if (v2.typeInfo == null && v1.typeInfo != null) {
				v2.typeInfo = v1.typeInfo
				changed = true
			} else {
				v1.typeInfo.doUnifyWith(v2.typeInfo)
			}
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
