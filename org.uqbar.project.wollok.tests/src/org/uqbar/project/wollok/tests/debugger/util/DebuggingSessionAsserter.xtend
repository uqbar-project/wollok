package org.uqbar.project.wollok.tests.debugger.util

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.tests.debugger.util.assertions.AfterAssertion
import org.uqbar.project.wollok.tests.debugger.util.assertions.BeforeAssertion

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * An object to configure assertions on the result of a debugging session.
 * 
 * @author jfernandes
 */
@Accessors
class DebuggingSessionAsserter {
	var TestDebugger debugger
	
	new(TestDebugger debugger) {
		this.debugger = debugger
	}
	
	def static escapedCode(EObject s) {
		s.sourceCode.replaceAll('\n', ' ').replaceAll('\\s+', ' ').trim()
	}
	
	def assertThat() { this }
	
	def before((InterpreterAssertion)=>void configurer) {
		setupAssertion(new BeforeAssertion, configurer)
	}
	
	def after((InterpreterAssertion)=>void configurer) {
		setupAssertion(new AfterAssertion, configurer)
	}
	
	protected def setupAssertion(InterpreterAssertion assertion, (InterpreterAssertion)=>void configurer) {
		debugger.addAssertion(assertion)
		configurer.apply(assertion)
		return this
	}
	
}

