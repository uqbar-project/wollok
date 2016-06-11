package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author jfernandes
 */
class NumberTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void integersAsResultValueOfNative() {
		'''program a {
			assert.equals(4, "hola".length())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void sum() {
		'''program a {
			assert.equals(4, 3 + 1)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void times() {
		'''program a {
			var x = 0
			6.times { x += 1 }
			assert.equals(6, x)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void integersFromNativeObjects() {
		'''program a {
		
			assert.equals(3, "hola".length() - 1)
		
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void integersBetwenTrue() {
		'''program a {
		
			assert.that(3.between(1, 5))
		
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void integersBetweenFalse() {
		'''program a {
		
			assert.notThat(3.between(5, 9))
		
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void absoluteValueOfAPositiveInteger() {
		'''program a {
		
			assert.equals(3, 3.abs())
		
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void absoluteValueOfANegativeInteger() {
		'''program a {
		
			assert.equals(3, (-3).abs())
		
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void squareRoot() {
		'''program a {
		
			assert.equals(9, 3.squareRoot())
		
		}
		'''.interpretPropagatingErrors
	}
	
}