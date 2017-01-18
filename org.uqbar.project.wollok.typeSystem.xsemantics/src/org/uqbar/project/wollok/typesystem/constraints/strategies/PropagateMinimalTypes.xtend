package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeState.*

class PropagateMinimalTypes extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		val supertypes = tvar.allSupertypes
		tvar.minimalConcreteTypes.entrySet.forEach [
			if (value == Pending) {
				val localChanged = tvar.propagateMinType(key, supertypes)
				if (!localChanged)
					println('''	Propagating min(«key») from: «tvar» to nowhere => «Ready»''')
				value = Ready
				changed = true
			}
		]
	}

	protected def boolean propagateMinType(TypeVariable tvar, WollokType key, Iterable<TypeVariable> supertypes) {
		supertypes.exists [ supertype |
			val newState = supertype.addMinimalType(key)
			val localChanged = newState != Ready

			if (localChanged)
				println('''	Propagating min(«key») from: «tvar» to «supertype» => «newState»''')

			localChanged
		]
	}
}
