package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry

abstract class AbstractInferenceStrategy {
	@Accessors
	var Boolean changed

	@Accessors
	var extension TypeVariablesRegistry registry

	def boolean run() {
		println('''Running strategy: «class.simpleName»''')
		var globalChanged = false

		do {
			changed = false
			allVariables.forEach[if (!it.hasErrors) it.analiseVariable]
			globalChanged = globalChanged || changed
		} while (changed)

		println('''Ending «if (globalChanged) "with" else "WITHOUT"» changes''')
		return globalChanged
	}

	abstract def void analiseVariable(TypeVariable tvar)
}
