package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo

class PropagateMaximalTypes extends SimpleTypeInferenceStrategy {
	override analiseSimpleType(TypeVariable tvar, SimpleTypeInfo type) {
		if (type.maximalConcreteTypes != null && tvar.maximalConcreteTypes.state == Pending) {
			type.propagateMaxTypes(tvar)
			type.maximalConcreteTypes.state = Ready
			changed = true
		}
	}

	def void propagateMaxTypes(SimpleTypeInfo type, TypeVariable tvar) {
		tvar.allSubtypes.forEach [ subtype |
			subtype.maximalConcreteTypes = type.maximalConcreteTypes
			println('''	Propagating «type.maximalConcreteTypes» from: «tvar» to «subtype»''')
		]
	}
}
