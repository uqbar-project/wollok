package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo

class PropagateMaximalTypes extends SimpleTypeInferenceStrategy {
	override analiseSimpleType(TypeVariable user, SimpleTypeInfo it) {
		if (maximalConcreteTypes != null && maximalConcreteTypes.state == Pending) {
			propagateMaxTypes(user)
			maximalConcreteTypes.state = Ready
			changed = true
		}
	}

	def void propagateMaxTypes(SimpleTypeInfo it, TypeVariable user) {
		user.allSubtypes.forEach [ subtype |
			subtype.maximalConcreteTypes = maximalConcreteTypes
			println('''	Propagating «maximalConcreteTypes» from: «user» to «subtype»''')
		]
	}
}
