package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class NullTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void messageSentToNull() {
		'''
		assert.throwsException({ null.sayHi() })
		'''.test
	}

	@Test
	def void operatorSentToNull() {
		'''
		assert.throwsException({ null + 3 })
		'''.test
	}
	
}