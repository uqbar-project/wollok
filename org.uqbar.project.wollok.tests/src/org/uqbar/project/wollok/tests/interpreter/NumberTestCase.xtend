package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.wollokToJava

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
	def void add() {
		'''
		assert.equals(4, 3 + 1)
		assert.equals(4.0, 3.0 + 1)
		assert.equals(4.0, 3.0 + 1.0)
		assert.equals(4.0, 3 + 1.0)
		assert.equals(4, 4 + 0.0)
		assert.equals(4, 4.0 + 0.0)
		assert.equals(4, 4.0 + 0)
		assert.equals(4, 4 + 0)
		'''.test
	}

	@Test
	def void addSeveralDecimals() {
		'''
		assert.equals(4.00001, 3.000004 + 1.000006)
		assert.equals(4.00001, 3.000002 + 1.000006)
		assert.equals(4, 3.000002 + 1.000002)
		'''.test
	}

	@Test
	def void subtractSeveralDecimals() {
		'''
		assert.equals(-0.00001, 4.000004 - 4.000006)
		assert.equals(0, 4.000007 - 4.000006)
		assert.equals(2, 3.000002 - 1.000001)
		assert.equals(1.99999, 3.000002 - 1.000006)
		assert.equals(1.99978, 3.000002 - 1.000222)
		'''.test
	}

	@Test
	def void multiply() {
		'''
		assert.equals(8, 4 * 2)
		assert.equals(8.0, 4 * 2.0)
		assert.equals(8.0, 4.0 * 2.0)
		assert.equals(8.0, 4.0 * 2)
		'''.test
	}
	
	@Test
	def void multiplySeveralDecimals() {
		'''
		assert.equals(8, 4.00000000001 * 2.000000000003)
		assert.equals(0, 4.00222222222222000000001 * 0)
		assert.equals(4.00270, 4.00222222222222000000001 * 1.00012)
		assert.equals(4.00415, 4.00222522222222000000001 * 1.00048)
		'''.test
	}

	@Test
	def void multiplyByZero() {
		'''
		assert.equals(6.2500000 * 0.5 * 0, 0)
		assert.equals(6.2500000 * 0, 0)
		assert.equals(0.0 * 0, 0)
		assert.equals(0.0 * 0.0, 0)
		assert.equals(0 * 0.0, 0)
		'''.test
	}

	@Test
	def void divide() {
		'''
		assert.equals(0.3, 3 / 10)
		assert.equals(2.5, 5 / 2)
		assert.equals(2, 4 / 2)
		assert.equals(2, 4 / 2.0)
		'''.test
	}

	@Test
	def void divideZero() {
		'''
		assert.equals(0, 0 / 10)
		assert.equals(0, 0 / 10.0)
		assert.equals(0, 0.0 / 10.0)
		assert.equals(0, 0 / 10.0)
		assert.equals(0, 0 / 100.0)
		assert.equals(0, 1 / 100000000000.0)
		'''.test
	}

	@Test
	def void divideSeveralDecimals() {
		'''
		assert.equals(0.51235, 5.123456 / 10.00000011)
		assert.equals(0.51235, 5.123456 / 10)
		assert.equals(0.51235, 5123456 / 10000000)		
		'''.test
	}

	@Test
	def void divisionByZero() {
		'''
		assert.throwsExceptionWithMessage("/ by zero", { 1 / 0 })
		assert.throwsExceptionWithMessage("/ by zero", { 1.0 / 0 })
		assert.throwsExceptionWithMessage("/ by zero", { 1.0 / 0.0 })
		assert.throwsExceptionWithMessage("/ by zero", { 1 / 0.0 })
		'''.test
	}

	@Test
	def void dividePeriodicDecimals() {
		'''
		assert.equals(0.72727, 40 / 55)
		assert.equals(0.72727, 40 / 55.0)
		assert.equals(0.72727, 40.0 / 55.0)
		assert.equals(0.72727, 40.0 / 55)
		assert.equals(0.33333, 1 / 3)
		assert.equals(0.66667, 2 / 3)
		'''.test
	}

	@Test
	def void divideDecimals() {
		'''
		assert.equals(0.3, 3 / 10.0)
		assert.equals(0.3, 3.0 / 10.0)
		assert.equals(2.5, 5 / 2.0)
		assert.equals(2, 4.0 / 2.0)
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
		assert.equals(0, 0.abs())
		assert.equals(0, 0.0.abs())
		assert.equals(60, (-60.0).abs())
		assert.equals(60.664, (-60.664).abs())
		assert.equals(60.664, (60.664).abs())
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
		assert.equals(0.11521, 1.1152112.rem(1.0000002))
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
		} catch (WollokProgramExceptionWrapper e) {
			assertTrue(e.wollokMessage.startsWith("5.5 does not understand gcd(p0)"))
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
		} catch (WollokProgramExceptionWrapper e) {
			assertTrue(e.wollokMessage.startsWith("gcd expects an integer as first argument"))
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

	@Test
	def void printString() {
		'''
		assert.equals("4", 4.printString())
		assert.equals("4.1", (4.1).printString())
		'''.test
	}	

	@Test
	def void negativeExponentiation() {
		'''
		assert.equals(0.2, 5 ** (-1))
		assert.equals(0.2, 5 ** (-1.0))
		assert.equals(0.2, 5.0 ** (-1.0))
		assert.equals(0.2, 5.0 ** (-1))
		assert.equals(1, 5.0 ** 0)
		assert.equals(1, 5.0 ** 0.0)
		assert.equals(1, 5 ** 0)
		assert.equals(1, 5 ** 0.0)
		'''.test
	}
	
	@Test
	def void integerExponentiation() {
		'''
		assert.equals(25, 5 ** 2)
		assert.equals(25, 5 ** 2.0)
		assert.equals(25.0, 5.0 ** 2)
		assert.equals(25.0, 5.0 ** 2.0)
		'''.test
	}
	
	@Test
	def void integerRoundUp() {
		'''
		assert.equals(5, (10/2).roundUp(2))
		'''.test
	}

	@Test
	def void integerTruncate() {
		'''
		assert.equals(5, (10/2).truncate(2))
		'''.test
	}
	
	@Test
	def void doubleRoundUp() {
		'''
		assert.equals(1.3, (5/4).roundUp(1))
		'''.test
	}

	@Test
	def void doubleTruncate() {
		'''
		assert.equals(1.2, (5/4).truncate(1))
		'''.test
	}

	@Test
	def void modulus() {
		'''
		assert.equals(1, 5 % 4)
		assert.equals(1.5, 5.5 % 4)
		assert.equals(0, 4 % 4)
		assert.equals(0, 4.0 % 4)
		assert.equals(0, 4.0 % 1)
		'''.test
	}

	@Test
	def void numberComparison() {
		'''
		assert.that((1.1 / 1) > (1.000002))
		assert.that(1 < 1.0001)
		assert.notThat(1 < 1)
		assert.notThat(1 > 1)
		assert.that(1 <= 1)
		assert.that(1 >= 1)
		'''.test
	}

	@Test
	def void veryBigIntegerAdd() {
		'''
		var a = 100000000000000000
		assert.equals(100000000000000001, a + 1)
		'''.test
	}

	@Test
	def void veryBigIntegerMultiply() {
		'''
		var a = 100000000000000000
		assert.equals(100000000000000000, a * 1)
		'''.test
	}

	@Test
	def void veryBigIntegerDivide() {
		'''
		var a = 100000000000000000
		assert.equals(100000, a / 1000000000000)
		'''.test
	}

}