package org.uqbar.project.wollok.tests.debugger

import org.eclipse.xtext.xbase.scoping.batch.ITypeImporter.Client
import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.mockito.Mockito
import org.uqbar.project.wollok.interpreter.api.XDebugger

import static extension org.mockito.Mockito.*
import org.junit.Test
import org.mockito.ArgumentCaptor
import org.eclipse.emf.ecore.EObject

/**
 * Tests the wollok interpreter debugging functions.
 * It doesn't have any of the "client" side debugger code tests.
 * 
 * @author jfernandes
 */
class DebugTestCase extends AbstractWollokInterpreterTestCase {
	
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
	
	
	
	
	
}