package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import static org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeState.*

class PropagateMaximalTypes extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		if (tvar.maximalConcreteTypes != null && tvar.maximalConcreteTypes.state == Pending) {
			tvar.propagateMaxTypes
			tvar.maximalConcreteTypes.state = Ready
		}
	}

	def void propagateMaxTypes(TypeVariable tvar) {
		tvar.subtypes.forEach [ subtype |
			if (tvar.unifiedWith(subtype)) {
				subtype.propagateMaxTypes
			} else {
				println('''	Propagating «tvar.maximalConcreteTypes» from: «tvar» to «subtype»''')
				subtype.maximalConcreteTypes = tvar.maximalConcreteTypes
			}
		]
	}
}
