package org.uqbar.project.wollok.interpreter

import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokNativeLobby
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.launch.Messages
import org.uqbar.project.wollok.wollokDsl.WVariable

/**
 * Special case when the REPL is running, stores the local program variables during the execution of different programs.
 */
@Singleton
class WollokREPLInterpreter extends WollokInterpreter {
	@Accessors val previousREPLVariables = <String, WVariable>newHashMap
	val nativeLobby = new WollokNativeLobby(console, this)


	def addREPLVariable(WVariable variable) {
		if (previousREPLVariables.containsKey(variable.name)) {
			throw new RuntimeException(NLS.bind(Messages.WollokLauncher_REFERENCE_ALREADY_DEFINED, variable.name))
		}
		previousREPLVariables.put(variable.name, variable)
	}
	
	// It uses always the same NativeLobby to keep the value of the local REPL variables.
	override createInitialStackElement(EObject root) {
		new XStackFrame(root, nativeLobby, WollokSourcecodeLocator.INSTANCE)
	}

	override isRootFile() { true }
}
