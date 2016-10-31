package org.uqbar.project.wollok.typesystem.constraints

class PropagateMinimalTypes {
	var Boolean changed
	val extension TypeVariablesRegistry registry

	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def run() {
		do {
			changed = false
			allVariables.forEach [ tvar |
				tvar.minimalConcreteTypes.entrySet.forEach [
					if (value == TypeVariable.ConcreteTypeState.Pending) {
						fullReport
						tvar.supertypes.forEach [ superType |
							superType.addMinimalType(key)
						]
						value = TypeVariable.ConcreteTypeState.Ready
						changed = true
					}
				]
			]
		} while (changed)

	}
}
