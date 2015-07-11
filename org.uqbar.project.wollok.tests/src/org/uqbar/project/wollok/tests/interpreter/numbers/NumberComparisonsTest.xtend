package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

class NumberComparisonsTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String expression

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		'''
			that(2 > 1)
			notThat(1 > 1)
			notThat(1 > 2)

			that(2 >= 1)
			that(1 >= 1)
			notThat(1 >= 2)

			notThat(2 < 1)
			notThat(1 < 1)
			that(1 < 2)

			notThat(2 <= 1)
			that(1 <= 1)
			that(1 <= 2)
			
			that(2 > 1.0)
			notThat(1 > 1.0)
			notThat(1 > 2.0)

			that(2 >= 1.0)
			that(1 >= 1.0)
			notThat(1 >= 2.0)

			notThat(2 < 1.0)
			notThat(1 < 1.0)
			that(1 < 2.0)

			notThat(2 <= 1.0)
			that(1 <= 1.0)
			that(1 <= 2.0)
			
			that(2.0 > 1)
			notThat(1.0 > 1)
			notThat(1.0 > 2)

			that(2.0 >= 1)
			that(1.0 >= 1)
			notThat(1.0 >= 2)

			notThat(2.0 < 1)
			notThat(1.0 < 1)
			that(1.0 < 2)

			notThat(2.0 <= 1)
			that(1.0 <= 1)
			that(1.0 <= 2)
			
			that(2.0 > 1.0)
			notThat(1.0 > 1.0)
			notThat(1.0 > 2.0)

			that(2.0 >= 1.0)
			that(1.0 >= 1.0)
			notThat(1.0 >= 2.0)

			notThat(2.0 < 1.0)
			notThat(1.0 < 1.0)
			that(1.0 < 2.0)

			notThat(2.0 <= 1.0)
			that(1.0 <= 1.0)
			that(1.0 <= 2.0)
			
		'''.lines.asParameters
	}
		
	@Test
	def void runAssertion() { assertion.interpretPropagatingErrors }

	def assertion() ''' program p { assert.«expression» } '''
}