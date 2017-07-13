package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry

abstract class AbstractInferenceStrategy {
	@Accessors
	var Boolean changed

	val Logger log = Logger.getLogger(this.class)

	@Accessors
	var extension TypeVariablesRegistry registry

	def boolean run() {
		log.debug('''Running strategy: «class.simpleName»''')
		var globalChanged = false

		do {
			changed = false
			allVariables.forEach[if (!it.hasErrors) it.analiseVariable]
			globalChanged = globalChanged || changed
		} while (changed)

		log.debug('''Ending «if (globalChanged) "with" else "WITHOUT"» changes''')
		return globalChanged
	}

	abstract def void analiseVariable(TypeVariable tvar)
}
