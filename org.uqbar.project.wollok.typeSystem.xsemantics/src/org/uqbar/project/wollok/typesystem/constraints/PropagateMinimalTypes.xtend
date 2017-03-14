package org.uqbar.project.wollok.typesystem.constraints

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable.ConcreteTypeState

abstract class AbstractInferenceStrategy {
	@Accessors
	var Boolean changed
	
	@Accessors
	var extension TypeVariablesRegistry registry

	def run() {
		println('''Running strategy: «class.simpleName»''')
		var globalChanged = false

		do {
			changed = false
			allVariables.forEach[if (!it.hasErrors) it.analiseVariable]
			globalChanged = globalChanged || changed
		} 
		while (changed)

		globalChanged
	}
	
	abstract def void analiseVariable(TypeVariable tvar) 	
}

class PropagateMinimalTypes extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		tvar.minimalConcreteTypes.entrySet.forEach [
			if (value == TypeVariable.ConcreteTypeState.Pending) {
				tvar.supertypes.forEach [ supertype |
					supertype.addMinimalType(key) => [ result |
						if (result != ConcreteTypeState.Ready) {
							println('''	Propagating min(«key») from: «tvar» to «supertype» => «result»''')
						}
					]
				]
				value = TypeVariable.ConcreteTypeState.Ready
				changed = true
			}
		]
	}
}

class PropagateMaximalTypes extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		if(tvar.maximalConcreteTypes != null && tvar.maximalConcreteTypes.state == TypeVariable.ConcreteTypeState.Pending) {
			tvar.subtypes.forEach [ subtype |
				println('''	Propagating «tvar.maximalConcreteTypes» from: «tvar» to «subtype»''')
				subtype.maximalConcreteTypes = tvar.maximalConcreteTypes
			]
			
			tvar.maximalConcreteTypes.state = TypeVariable.ConcreteTypeState.Ready
		}
	}
}