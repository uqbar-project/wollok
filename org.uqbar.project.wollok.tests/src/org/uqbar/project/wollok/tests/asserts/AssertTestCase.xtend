package org.uqbar.project.wollok.tests.asserts

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

class AssertTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void assertUsingPrintString() {
		'''
		assert.throwsExceptionWithMessage('Expected [[true]] but found ["[true]"]', { assert.equals([true], "[true]") })
		'''.test
	}
	
	@Test
	def void assertNotTrueFails() {
		'''
		assert.throwsExceptionLike(new AssertionException("Value was not true"),{ => assert.that(false) } )
		'''.test
	}
}