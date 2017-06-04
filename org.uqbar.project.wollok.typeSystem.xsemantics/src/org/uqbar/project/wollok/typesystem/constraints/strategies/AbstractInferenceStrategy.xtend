package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.TypeVariablesRegistry

abstract class AbstractInferenceStrategy {
	@Accessors
	var Boolean changed

	@Accessors
	var extension TypeVariablesRegistry registry

	def Boolean run() {
		println('''Running strategy: «class.simpleName»''')
		var globalChanged = false

		do {
			changed = false
			allVariables.forEach[if (!it.hasErrors) it.analiseVariable]
			globalChanged = globalChanged || changed
		} while (changed)

		println('''Ending «if (globalChanged) "with" else "WITHOUT"» changes''')
		globalChanged
	}

	abstract def void analiseVariable(TypeVariable tvar)
}
