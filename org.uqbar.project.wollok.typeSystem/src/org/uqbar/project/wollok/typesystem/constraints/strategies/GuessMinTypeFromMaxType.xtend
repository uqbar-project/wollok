package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.SimpleTypeInfo

class GuessMinTypeFromMaxType extends SimpleTypeInferenceStrategy {
	def dispatch analiseVariable(TypeVariable tvar, SimpleTypeInfo it) {
		if (minimalConcreteTypes.isEmpty && maximalConcreteTypes != null) {
			maximalConcreteTypes.forEach [ type |
				addMinimalType(type)
			]
			changed = true
		}
	}
	
}
