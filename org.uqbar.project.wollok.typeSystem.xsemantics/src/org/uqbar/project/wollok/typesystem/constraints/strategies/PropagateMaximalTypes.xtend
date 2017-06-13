package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import static org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeState.*

class PropagateMaximalTypes extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		if (tvar.maximalConcreteTypes != null && tvar.maximalConcreteTypes.state == Pending) {
			tvar.propagateMaxTypes(tvar.allSubtypes)
			tvar.maximalConcreteTypes.state = Ready
			changed = true
		}
	}

	def void propagateMaxTypes(TypeVariable tvar, Iterable<TypeVariable> subtypes) {
		subtypes.forEach [ subtype |
			subtype.maximalConcreteTypes = tvar.maximalConcreteTypes
			println('''	Propagating «tvar.maximalConcreteTypes» from: «tvar» to «subtype»''')
		]
	}
}
