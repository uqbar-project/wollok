package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo

class PropagateMaximalTypes extends SimpleTypeInferenceStrategy {
	def dispatch analiseVariable(TypeVariable user, SimpleTypeInfo it) {
		println('''Analising maxTypes of «user»''')
		if (maximalConcreteTypes == null) {
			println('''	No maxType info''')
			return
		}
		if (maximalConcreteTypes.state != Pending) {
			println(''' No pending maxTypes to propagete, state=«maximalConcreteTypes.state»''')
			return	
		}

		// Do propagate		
		propagateMaxTypes(user)
		maximalConcreteTypes.state = Ready
		changed = true
	}

	def void propagateMaxTypes(SimpleTypeInfo it, TypeVariable user) {
		user.allSubtypes.forEach [ subtype |
			subtype.setMaximalConcreteTypes(maximalConcreteTypes, user)
			println('''	Propagating «maximalConcreteTypes» from: «user» to «subtype»''')
		]
	}
}
