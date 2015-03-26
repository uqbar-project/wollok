package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

class WollokArithmeticTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String expression

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		'''
			assert(1 == 1)
			assert(1 == 1.0)
			assert(1.0 == 1)
			assert(1.0 == 1.0)
			
			assertFalse(1 == 2)
			assertFalse(1.0 == 2)
			assertFalse(1 == 2.0)
			assertFalse(1.0 == 2.0)
			
			assert(1 != 2)
			assert(1 != 2.0)
			assert(1.0 != 2)
			assert(1.0 != 2.0)
			
			assertFalse(1 != 1)
			assertFalse(1.0 != 1)
			assertFalse(1 != 1.0)
			assertFalse(1.0 != 1.0)			
		'''.lines.asParameters
	}
		
	@Test
	def void runAssertion() { assertion.interpretPropagatingErrors }

	def assertion() ''' program p { this.«expression» } '''
}