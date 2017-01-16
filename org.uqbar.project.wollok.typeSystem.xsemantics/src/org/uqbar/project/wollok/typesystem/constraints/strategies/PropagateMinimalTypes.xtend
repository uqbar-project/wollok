package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeState
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable

import static org.uqbar.project.wollok.typesystem.constraints.ConcreteTypeState.*

class PropagateMinimalTypes extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		tvar.minimalConcreteTypes.entrySet.forEach [
			if (value == Pending) {
				tvar.supertypes.forEach [ supertype |
					supertype.addMinimalType(key) => [ result |
						if (result != ConcreteTypeState.Ready) {
							println('''	Propagating min(«key») from: «tvar» to «supertype» => «result»''')
						}
					]
				]
				value = Ready
				changed = true
			}
		]
	}
}
