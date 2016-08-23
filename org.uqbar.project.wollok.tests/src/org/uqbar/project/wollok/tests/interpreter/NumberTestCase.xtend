package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * 
 * @author jfernandes
 * @author dodain
 */
class NumberTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void integersAsResultValueOfNative() {
		'''
		assert.equals(4, "hola".length())
		'''.test
	}
	
	@Test
	def void sum() {
		'''
		assert.equals(4, 3 + 1)
		'''.test
	}
	
	@Test
	def void times() {
		'''
		var x = 0
		6.times { x += 1 }
		assert.equals(6, x)
		'''.test
	}

	@Test
	def void integersFromNativeObjects() {
		'''
		assert.equals(3, "hola".length() - 1)
		'''.test
	}

	@Test
	def void integersBetweenTrue() {
		'''
		assert.that(3.between(1, 5))
		'''.test
	}

	@Test
	def void integersBetweenFalse() {
		'''
		assert.notThat(3.between(5, 9))
		'''.test
	}

	@Test
	def void absoluteValueOfAPositiveInteger() {
		'''
		assert.equals(3, 3.abs())
		'''.test
	}

	@Test
	def void absoluteValueOfANegativeInteger() {
		'''
		assert.equals(3, (-3).abs())
		'''.test
	}

	@Test
	def void squareRoot() {
		'''
		assert.equals(3, 9.squareRoot())
		'''.test
	}

	@Test
	def void square() {
		'''
		assert.equals(9, 3.square())
		'''.test
	}

	@Test
	def void lessThan() {
		'''
		assert.that(3 < 7)
		assert.notThat(13 < 7)
		'''.test
	}
	
	@Test
	def void remainder() {
		'''
		const remainder = 17.rem(7)
		const remainder2 = 12.rem(6)
		assert.equals(3, remainder)
		assert.equals(0, remainder2)
		'''.test
	}
	
	@Test
	def void even() {
		'''
		assert.notThat(3.even())
		assert.that(260.even())
		'''.test
	}
	
	@Test
	def void odd() {
		'''
		assert.that(3.odd())
		assert.notThat(260.odd())
		'''.test
	}

	@Test
	def void gcd() {
		'''
		const gcd1 = 5.gcd(25)
		const gcd2 = 25.gcd(20)
		const gcd3 = 2.gcd(3)
		assert.equals(5, gcd1)
		assert.equals(5, gcd2)
		assert.equals(1, gcd3)
		'''.test
	}

	@Test
	def void gcdForDecimalsIsInvalid() {
		try {
		'''
		program a {
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
		'''
		program a {
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
		'''
		const lcm1 = 5.lcm(25)
		const lcm2 = 7.lcm(8)
		const lcm3 = 10.lcm(15)
		assert.equals(25, lcm1)
		assert.equals(56, lcm2)
		assert.equals(30, lcm3)
		'''.test
	}
	
	@Test
	def void digits() {
		'''
		assert.equals(4, 1024.digits())
		assert.equals(3, (-220).digits())
		'''.test
	}	

	@Test
	def void isPrime() {
		'''
		assert.that(3.isPrime())
		assert.notThat(4.isPrime())
		assert.that(5.isPrime())
		assert.notThat(88.isPrime())
		assert.that(17.isPrime())
		'''.test
	}	

	@Test
	def void randomForIntegers() {
		'''
		const random1 = 3.randomUpTo(8)
		assert.that(random1.between(3, 8))
		assert.notThat(random1.between(9, 10))
		'''.test
	}	

	@Test
	def void randomForReals() {
		'''
		const random1 = (3.2).randomUpTo(8.9)
		assert.that(random1.between(3.2, 8.9))
		assert.notThat(random1.between(9.0, 10.11))
		'''.test
	}	

	@Test
	def void integerDivision() {
		'''
		assert.equals(4, 16.div(4))
		assert.equals(4, 18.div(4))
		assert.equals(5, 21.div(4))
		assert.equals(5, (21.2).div(4.1))
		'''.test
	}	

}