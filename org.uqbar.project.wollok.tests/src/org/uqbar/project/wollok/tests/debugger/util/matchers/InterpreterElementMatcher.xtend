package org.uqbar.project.wollok.tests.debugger.util.matchers

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

import static extension org.uqbar.project.wollok.tests.debugger.util.DebuggingSessionAsserter.*

/**
 * Strategy to match and element while interpreting (debugging?)
 * 
 * @author jfernandes
 */
interface InterpreterElementMatcher {
	
	def boolean matches(Pair<EObject, XStackFrame> evaluationState);
	
	// factory methods to use as dsl-like
	
	/** Matches if the AST node being evaluated is equals to the given sentence string (without taking into account spaces and newlines) */
	def static InterpreterElementMatcher codeIs(String sentence) {[ 
		key.escapedCode == sentence
	]}
	
}