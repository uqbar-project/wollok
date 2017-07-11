package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*

class PropagateMinimalTypes extends SimpleTypeInferenceStrategy {
	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo typeInfo) {
		val supertypes = tvar.allSupertypes
		typeInfo.minTypesDo(tvar)[
			if (state == Pending) {
//				val localChanged = 
				tvar.propagateMinType(type, supertypes)
//				if (!localChanged)
//					println('''	Propagating min(«type») from: «tvar» to nowhere => «Ready»''')

				ready
				changed = true
			}
		]
	}

	protected def boolean propagateMinType(TypeVariable origin, WollokType key, Iterable<TypeVariable> supertypes) {
		supertypes.evaluate[ supertype |
			val newState = supertype.addMinType(key, origin)
			(newState != Ready)
				=> [ if (it) println('''	Propagating min(«key») from: «origin» to «supertype» => «newState»''')]
		]
	}
	
	def boolean evaluate(Iterable<TypeVariable> variables, (TypeVariable)=>boolean action) {
		variables.fold(false)[hasChanges, variable | action.apply(variable) || hasChanges ]
	}
	
}
