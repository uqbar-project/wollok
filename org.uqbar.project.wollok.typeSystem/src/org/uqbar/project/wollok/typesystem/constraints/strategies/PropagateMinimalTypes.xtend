package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class PropagateMinimalTypes extends SimpleTypeInferenceStrategy {
	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo type) {
		val supertypes = tvar.allSupertypes
		type.minimalConcreteTypes.entrySet.forEach [
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
