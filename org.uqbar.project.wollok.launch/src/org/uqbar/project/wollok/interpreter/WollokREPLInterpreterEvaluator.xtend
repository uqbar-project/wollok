package org.uqbar.project.wollok.interpreter

import org.uqbar.project.wollok.launch.WollokLauncherInterpreterEvaluator
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

class WollokREPLInterpreterEvaluator extends WollokLauncherInterpreterEvaluator {
	
	override _evaluate(WVariableDeclaration it) {
		val WollokREPLInterpreter replInterpreter = interpreter as WollokREPLInterpreter
		if (it.eContainer instanceof WProgram) {
			replInterpreter.addREPLVariable(variable)
		}
		super._evaluate(it)
	}
	
}