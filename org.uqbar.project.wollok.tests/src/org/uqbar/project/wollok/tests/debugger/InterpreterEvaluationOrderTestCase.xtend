package org.uqbar.project.wollok.tests.debugger

import org.eclipse.emf.ecore.EObject
import org.junit.Test
import org.mockito.ArgumentCaptor
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.tests.debugger.util.AbstractXDebuggerImplTestCase

import static extension org.mockito.Mockito.*

/**
 * Tests the wollok interpreter debugging functions.
 * It doesn't have any of the "client-side" debugger code tests.
 * 
 * It asserts a given program evaluation order and the expected calls
 * to XDebugger methods
 * 
 * @author jfernandes
 */
class InterpreterEvaluationOrderTestCase extends AbstractXDebuggerImplTestCase {
	
	@Test
	def void callsStartedAndTerminated() {
		val debugger = XDebugger.mock
		interpreter.addInterpreterListener(debugger)
		'''
		program a {
			const one = 1
			const two = 2
			const sum = one + 2
		}'''.interpretPropagatingErrors
		
		verify(debugger, times(1)).started
		verify(debugger, times(1)).terminated
	}
	
	@Test
	def void aboutToEvaluateMustBeCalledSameTimesAsEvaluatedAndWithTheSameElements() {
		val debugger = XDebugger.mock
		val aboutToEvaluateCaptor = ArgumentCaptor.forClass(EObject)
		val evaluatedCaptor = ArgumentCaptor.forClass(EObject)
		
		interpreter.addInterpreterListener(debugger)
		'''
		program a {
			const one = 1
			const two = 2
			const sum = one + 2
		}'''.interpretPropagatingErrors
		
		verify(debugger, times(9)).aboutToEvaluate(aboutToEvaluateCaptor.capture)
		verify(debugger, times(9)).evaluated(evaluatedCaptor.capture)
		
		assertEquals(aboutToEvaluateCaptor.allValues.size, evaluatedCaptor.allValues.size)
		aboutToEvaluateCaptor.allValues.forEach[ assertTrue(evaluatedCaptor.allValues.contains(it), "About was not evaluated: " + it) ]
	}
	
	
}