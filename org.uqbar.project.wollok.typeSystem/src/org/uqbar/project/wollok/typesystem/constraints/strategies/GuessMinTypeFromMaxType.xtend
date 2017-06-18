package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

class GuessMinTypeFromMaxType extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable it) {
		if (minimalConcreteTypes.isEmpty && maximalConcreteTypes != null) {
			maximalConcreteTypes.forEach [ type |
				addMinimalType(type)
			]
			changed = true
		}
	}
}
