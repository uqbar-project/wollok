package org.uqbar.project.wollok.typesystem.constraints.strategies

import java.util.Set
import org.uqbar.project.wollok.typesystem.WollokType
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

			v1.typeInfo.minimalConcreteTypes = minTypesUnion(v1, v2)
			v1.typeInfo.joinMaxTypes(v2.maximalConcreteTypes)

			v2.typeInfo.users.forEach[typeInfo = v1.typeInfo]

			changed = true
		}
	}

	protected def minTypesUnion(TypeVariable v1, TypeVariable v2) {
		(v1.minimalConcreteTypes.keySet + v2.minimalConcreteTypes.keySet).toSet.toInvertedMap [
			if (isReadyIn(v1) && isReadyIn(v2))
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
	def boolean isReadyIn(WollokType type, TypeVariable variable) {
		variable.minimalConcreteTypes.get(type) == Ready
	}

	def <T> T uniqueElement(Set<T> it) { iterator.next }

}
