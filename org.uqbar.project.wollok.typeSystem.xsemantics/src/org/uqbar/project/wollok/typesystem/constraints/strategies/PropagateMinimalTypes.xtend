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
		supertypes.evaluate[ supertype |
			val newState = supertype.addMinimalType(key)
			(newState != Ready)
				=> [ if (it) println('''	Propagating min(«key») from: «tvar» to «supertype» => «newState»''')]
		]
	}
	
	def boolean evaluate(Iterable<TypeVariable> variables, (TypeVariable)=>boolean action) {
		variables.fold(false)[hasChanges, variable | action.apply(variable) || hasChanges ]
	}
	
}
