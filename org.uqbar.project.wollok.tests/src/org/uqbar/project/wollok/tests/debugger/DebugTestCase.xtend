package org.uqbar.project.wollok.tests.debugger

import org.eclipse.emf.ecore.EObject
import org.junit.Test
import org.mockito.ArgumentCaptor
import org.uqbar.project.wollok.interpreter.api.XDebugger

import static extension org.mockito.Mockito.*

/**
 * Tests the wollok interpreter debugging functions.
 * It doesn't have any of the "client" side debugger code tests.
 * 
 * @author jfernandes
 */
class DebugTestCase extends AbstractWollokDebugTestCase {
	
	@Test
	def void callsStartedAndTerminated() {
		val debugger = XDebugger.mock
		interpreter.debugger = debugger
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
		
		interpreter.debugger = debugger
		'''
		program a {
			const one = 1
			const two = 2
			const sum = one + 2
		}'''.interpretPropagatingErrors
		
		verify(debugger, times(9)).aboutToEvaluate(aboutToEvaluateCaptor.capture)
		verify(debugger, times(9)).evaluated(evaluatedCaptor.capture)
		
		assertEquals(aboutToEvaluateCaptor.allValues.size, evaluatedCaptor.allValues.size)
		aboutToEvaluateCaptor.allValues.forEach[ assertTrue("About was not evaluated: " + it, evaluatedCaptor.allValues.contains(it)) ]
		
		println(aboutToEvaluateCaptor.allValues.join(','))
	}
	
	@Test
	def void stepByStepEvaluation() {
		val steps = debugSteppingInto('''
				program a {
					const one = 1
					const two = 2
					const sum = one + two
				}''')
		
		// 6 ? This was reverse engineer. Maybe the test is not right.		
		assertEquals(6, steps.size)
		
		// TODO: evaluate the stack state on each step
	}
	
}