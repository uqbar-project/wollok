package org.uqbar.project.wollok.tests.debugger.util.matchers

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * Strategy to match and element while interpreting (debugging?)
 * 
 * @author jfernandes
 */
interface InterpreterElementMatcher {
	
	def boolean matches(Pair<EObject, XStackFrame<WollokObject>> evaluationState);
}