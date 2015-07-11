package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

class NumberEqualityTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String expression

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		'''
			assert.that(1 == 1)
			assert.that(1 == 1.0)
			assert.that(1.0 == 1)
			assert.that(1.0 == 1.0)
			
			assert.notThat(1 == 2)
			assert.notThat(1.0 == 2)
			assert.notThat(1 == 2.0)
			assert.notThat(1.0 == 2.0)
			
			assert.that(1 != 2)
			assert.that(1 != 2.0)
			assert.that(1.0 != 2)
			assert.that(1.0 != 2.0)
			
			assert.notThat(1 != 1)
			assert.notThat(1.0 != 1)
			assert.notThat(1 != 1.0)
			assert.notThat(1.0 != 1.0)			
		'''.lines.asParameters
	}
		
	@Test
	def void runAssertion() { assertion.interpretPropagatingErrors }

	def assertion() ''' program p { «expression» } '''
}