package org.uqbar.project.wollok.tests.debugger.util.assertions

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

/**
 * Assertion that executes "before" evaluating the matching element.
 * 
 * @see AbstractInterpreterAssertion
 * 
 * @author jfernandes
 */
class BeforeAssertion extends AbstractInterpreterAssertion {

	override before(Pair<EObject, XStackFrame> state) {
		checkAndAssert(state)	
	}

}