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
	def void integersBetweenTrue() {
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
		
			assert.equals(3, 9.squareRoot())
		
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void square() {
		'''program a {
		
			assert.equals(9, 3.square())
		
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void lessThan() {
		'''program a {
		
			assert.that(3 < 7)
			assert.notThat(13 < 7)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void remainder() {
		'''program a {
			const remainder = 17.rem(7)
			const remainder2 = 12.rem(6)
			assert.equals(3, remainder)
			assert.equals(0, remainder2)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void even() {
		'''program a {
			assert.notThat(3.even())
			assert.that(260.even())
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void odd() {
		'''program a {
			assert.that(3.odd())
			assert.notThat(260.odd())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void gcd() {
		'''program a {
			const gcd1 = 5.gcd(25)
			const gcd2 = 25.gcd(20)
			const gcd3 = 2.gcd(3)
			assert.equals(5, gcd1)
			assert.equals(5, gcd2)
			assert.equals(1, gcd3)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void gcdForDecimalsIsInvalid() {
		try {
		'''program a {
			(5.5).gcd(12)
		}
		'''.interpretPropagatingErrors
			fail("decimals should not understand gcd message")
		} catch (AssertionError e) {
			assertTrue(e.message.startsWith("5.5 does not understand gcd(p0)"))
		}
	}

	@Test
	def void gcdForDecimalsIsInvalid2() {
		try {
		'''program a {
			console.println((5).gcd(12.3))
		}
		'''.interpretPropagatingErrors
			fail("gcd works also for decimal argument!!")
		} catch (AssertionError e) {
			assertTrue(e.message.startsWith("gcd expects an integer as first argument"))
		}
	}

	@Test
	def void lcm() {
		'''program a {
			const lcm1 = 5.lcm(25)
			const lcm2 = 7.lcm(8)
			const lcm3 = 10.lcm(15)
			assert.equals(25, lcm1)
			assert.equals(56, lcm2)
			assert.equals(30, lcm3)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void digits() {
		'''program a {
			assert.equals(4, 1024.digits())
			assert.equals(3, (-220).digits())
		}
		'''.interpretPropagatingErrors
	}	

	@Test
	def void isPrime() {
		'''program a {
			assert.that(3.isPrime())
			assert.notThat(4.isPrime())
			assert.that(5.isPrime())
			assert.notThat(88.isPrime())
			assert.that(17.isPrime())			
		}
		'''.interpretPropagatingErrors
	}	

	@Test
	def void randomForIntegers() {
		'''program a {
			const random1 = 3.randomUpTo(8)
			console.println(random1)
			assert.that(random1.between(3, 8))
			assert.notThat(random1.between(9, 10))
		}
		'''.interpretPropagatingErrors
	}	

	@Test
	def void randomForReals() {
		'''program a {
			const random1 = (3.2).randomUpTo(8.9)
			console.println(random1)
			assert.that(random1.between(3.2, 8.9))
			assert.notThat(random1.between(9.0, 10.11))
		}
		'''.interpretPropagatingErrors
	}	

}