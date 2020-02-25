package org.uqbar.project.wollok.tests.debugger.util.assertions

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * Assertion that executes "after" evaluating the matching element.
 * 
 * @see AbstractInterpreterAssertion
 * @see BeforeAssertion
 * 
 * @author jfernandes
 */
class AfterAssertion extends AbstractInterpreterAssertion {
	
	override after(Pair<EObject, XStackFrame<WollokObject>> state) {
		checkAndAssert(state)
	}
	
}