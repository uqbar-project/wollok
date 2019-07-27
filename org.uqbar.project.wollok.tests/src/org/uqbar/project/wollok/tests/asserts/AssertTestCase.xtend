package org.uqbar.project.wollok.tests.asserts

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.ComparisonFailure

class AssertTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void assertUsingPrintString() {
		'''
		assert.throwsExceptionWithMessage('Expected [[true]] but found ["[true]"]', { assert.equals([true], "[true]") })
		'''.test
	}
	
	@Test
	def void assertWhenNotTrueFails() {
		'''
		assert.throwsExceptionLike(new AssertionException(message = "Value was not true"),{ => assert.that(false) } )
		'''.test
	}
	
	@Test
	def void assertNotWhenNotFalseFails() {
		'''
		assert.throwsExceptionLike(new AssertionException(message = "Value was not false"),{ => assert.notThat(true) } )
		'''.test
	}

	@Test
	def void assertWithOneParameterShouldFail() {
		'''
		assert.throwsExceptionLike(
			new AssertionException(message = "assert.equals(expected, actual): missing second parameter"),
			{ => assert.equals(4) }
		)
		'''.test
	}
	
	@Test
	def void assertEqualsWhenEqualsWorks() {
		'''
		assert.equals(4, 4)
		'''.test
	}
	
	@Test
	def void assertEqualsWhenNotEqualsFails() {
		'''
		assert.throwsExceptionLike(new AssertionException(message = "Expected [2] but found [4]"),{ => assert.equals(2, 4) } )
		'''.test
	}
	
	@Test
	def void assertDifferentWhenEqualsFails() {
		'''
		assert.throwsExceptionLike(new AssertionException(message = "Expected to be different, but [4] and [4] match"),{ => assert.notEquals(4, 4) } )
		'''.test
	}	

	@Test
	def void assertDifferentWhenDifferentWorks() {
		'''
		assert.notEquals(4, 5)
		'''.test
	}	

	@Test
	def void failure() {
		'''
		assert.throwsExceptionLike(new AssertionException(message = "Kaboom"),{ => assert.fail("Kaboom") } )
		'''.test
	}
	
	@Test(expected = ComparisonFailure)
	def void assertIsTranslatedToComparisonFailure(){
		'''
		assert.equals(1, "hola")
		'''.test
	}

	@Test
	def void thatUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation that doesn't support null parameters", { => assert.that(null) })
		'''.test
	}

	@Test
	def void notThatUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation notThat doesn't support null parameters", { => assert.notThat(null) })
		'''.test
	}
	
	@Test
	def void throwsExceptionUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation throwsException doesn't support null parameters", { => assert.throwsException(null) })
		'''.test
	}
	
	@Test
	def void throwsExceptionLikeUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation throwsExceptionLike doesn't support null parameters", { => assert.throwsExceptionLike(null, null) })
		'''.test
	}

	@Test
	def void throwsExceptionWithMessageUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation throwsExceptionWithMessage doesn't support null parameters", { => assert.throwsExceptionWithMessage(null, null) })
		'''.test
	}

	@Test
	def void throwsExceptionWithTypeUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation throwsExceptionWithType doesn't support null parameters", { => assert.throwsExceptionWithType(null, null) })
		'''.test
	}
	
	@Test
	def void throwsExceptionByComparingUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation throwsExceptionByComparing doesn't support null parameters", { => assert.throwsExceptionByComparing(null, null) })
		'''.test
	}
	
}