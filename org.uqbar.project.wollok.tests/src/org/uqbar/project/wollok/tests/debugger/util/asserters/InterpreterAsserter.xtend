package org.uqbar.project.wollok.tests.debugger.util.asserters

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * Performs an assertion while interpreting/debugging.
 * 
 * They have the real logic to evaluate a given snapshot (state) of the execution.
 * 
 * For example you could assert that there are no variables in the current context.
 * Or that the given object is not null.
 * 
 * @see XStackFrame
 * 
 * @author jfernandes
 */
interface InterpreterAsserter {
	
	def void assertIt(Pair<EObject, XStackFrame<WollokObject>> pair)
	
}