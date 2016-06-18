package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class IntervalTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void containsMaxLimit() {
		'''
		assert.that(new Interval(2.2, 12.2).contains(12.2))
		'''.test
	}
	
	@Test
	def void containsMinLimit() {
		'''
		assert.that(new Interval(2.2, 12.2).contains(2.2))
		'''.test
	}

	@Test
	def void containsOk() {
		'''
		assert.that(new Interval(2.2, 12.2).contains(3.5))
		'''.test
	}

	@Test
	def void containsOkForIntsAlso() {
		'''
		assert.that(new Interval(2, 12).contains(3.5))
		'''.test
	}

	@Test
	def void containsOkForIntsAlso2() {
		'''
		assert.that(new Interval(2, 12).contains(3))
		'''.test
	}

	@Test
	def void containsNotOk() {
		'''
		assert.notThat(new Interval(2.2, 12.2).contains(23.5))
		'''.test
	}

	@Test
	def void random() {
		'''
		const interval = new Interval(2.2, 12.2)
		const random = interval.random()
		assert.that(interval.contains(random))
		'''.test
	}

	@Test
	def void intervalForStringsNotAllowed() {
		'''
		assert.throwsException({ => new Interval("A", 12.2)})
		assert.throwsException({ => new Interval(1, "E")})
		'''.test
	}
	
}