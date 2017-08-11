package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.typesystem.TypeSystemException

abstract class AbstractInferenceStrategy {
	@Accessors
	var Boolean changed

	@Accessors
	var Boolean globalChanged


	val Logger log = Logger.getLogger(this.class)

	@Accessors
	var TypeVariablesRegistry registry

	def boolean run() {
		log.debug('''Running strategy: «class.simpleName»''')
		globalChanged = false
		
		walkThrougProgram

		log.debug('''Ending «if (globalChanged) "with" else "WITHOUT"» changes''')
		return globalChanged
	}
	
	def void walkThrougProgram() {
		do {
			changed = false
			allVariables.forEach[walkThroughVariable]
			globalChanged = globalChanged || changed
		} while (changed)
	}

	/**
	 * Invokes #analiseVariable, with a general error handling.
	 * 
	 * Final line of error catching. Errors caught here will most probably be bugs,
	 * but it is still better to catch and inform,
	 * as it avoids breaking and improves debugging. 
	 */
	def walkThroughVariable(TypeVariable it) {
		if (!hasErrors) 
			try analiseVariable
			catch (TypeSystemException exception) addError(exception) 
	}

	abstract def void analiseVariable(TypeVariable tvar)
	
	def allVariables() { registry.allVariables }
	def allFiles() { registry.typeSystem.programs }
	def tvar(EObject node) { registry.tvar(node) }
}
