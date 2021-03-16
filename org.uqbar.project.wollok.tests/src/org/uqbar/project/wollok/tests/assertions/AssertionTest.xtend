package org.uqbar.project.wollok.tests.assertions

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author dodain
 */
class AssertionTest extends AbstractWollokInterpreterTestCase {
	
	def shouldFailTestForAssertObject(CharSequence test) {
		try {
			test.interpretPropagatingErrorsWithoutStaticChecks
			fail("Test should have failed")	
		} catch (Exception e) {
			assertEquals(e.cause.message, "No message to 'assert' object was sent")
		}
	}

	@Test
	def void testWithNoAssertShouldFail() {
		'''
		test "should fail a test with no assert" {
		}
		'''.shouldFailTestForAssertObject
	}
	
	@Test
	def void testUsingAssertButNotSendingAnyMessageShouldFail() {
		'''
		test "should fail a test using assert but calling no method" {
			assert
		}
		'''.shouldFailTestForAssertObject	
	}

	@Test
	def void testNotCallingAssertInElseShouldFail() {
		'''
		test "should fail avoid calling assert inside if" {
			var a = 5
			if (a > 1) a = 10 else assert.equals(1, 1)
		}
		'''.shouldFailTestForAssertObject	
	}

	@Test
	def void testNotCallingAssertInIfShouldFail() {
		'''
		test "should fail avoid calling assert inside else" {
			var a = 5
			if (a < 5) assert.equals(1, 1) else a = 10 
		}
		'''.shouldFailTestForAssertObject	
	}

	@Test
	def void testNotCallingAssertInTryShouldFail() {
		'''
		test "should fail avoid calling assert inside try" {
			try {
			} catch e : Exception {
				assert.equals(1, 1)
			}
		}
		'''.shouldFailTestForAssertObject	
	}

	def void testNotCallingAssertInCatchShouldPass() {
		'''
		test "should fail avoid calling assert inside try" {
			try {
				1 / 0
				assert.equals(1, 1)
			} catch e : Exception {
			}
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void testCallingAssertInThenAlwaysShouldNotFail() {
		'''
		test "should not fail calling assert in then always only" {
			try {
				1 / 0
			} catch e : Exception {
			} then always {
				assert.equals(1, 1)
			}
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks	
	}

	@Test
	def void testCallingAssertInBlockShouldNotFail() {
		'''
		test "should not fail calling assert inside block" {
			{ value => assert.equals(value, 1) }.apply(1)
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks	
	}
}