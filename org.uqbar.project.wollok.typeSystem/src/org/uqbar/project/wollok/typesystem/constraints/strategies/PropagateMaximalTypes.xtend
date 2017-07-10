package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.variables.ConcreteTypeState.*
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo

class PropagateMaximalTypes extends SimpleTypeInferenceStrategy {
	def dispatch analiseVariable(TypeVariable user, SimpleTypeInfo it) {
		if (maximalConcreteTypes == null) return;
		if (maximalConcreteTypes.state != Pending) return;

		// Do propagate		
		propagateMaxTypes(user)
		maximalConcreteTypes.state = Ready
		changed = true
	}

	def void propagateMaxTypes(SimpleTypeInfo it, TypeVariable user) {
		println('''	Analising maxTypes of «user»''')
		user.allSubtypes.forEach [ subtype |
			subtype.setMaximalConcreteTypes(maximalConcreteTypes, user)
			println('''		Propagating «maximalConcreteTypes» from: «user» to «subtype»''')
		]
	}
}
