package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests wollok ranges
 * 
 * @author jfernandes
 */
class RangeTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void testForEach() {
		'''
		const range = 0 .. 10
		var sum = 0
		assert.that(range != null)
		range.forEach { i => sum += i }
		assert.equals(55, sum)
		'''.test
	}

	@Test
	def void fold() {
		'''
		var range = 0 .. 10 
		var sum = range.fold(0, { acum, each => acum + each })
		assert.equals(55, sum)
		'''.test
	}

	@Test
	def void sum() {
		'''
		var range = 0 .. 9 
		assert.equals(45, range.sum())
		'''.test
	}

	@Test
	def void sumClosure() {
		'''
		var range = 0 .. 9 
		assert.equals(90, range.sum({ n => n * 2 }))
		'''.test
	}

	@Test
	def void contains() {
		'''
		var range = 0 .. 9 
		assert.that(range.contains(9))
		assert.that(range.contains(0))
		assert.that(range.contains(4))
		assert.notThat(range.contains(-1))
		assert.notThat(range.contains(10))
		'''.test
	}
		
	@Test
	def void size() {
		'''
		assert.equals(11, (0..10).size())
		assert.equals(10, (12..21).size())
		assert.equals(7, (-3..3).size())
		'''.test
	
	}
	
	@Test
	def void isEmpty() {
		'''
		assert.notThat((0..10).isEmpty())
		assert.notThat((0 .. 0).isEmpty())
		'''.test
	}
	
	@Test
	def void any() {
		'''
		assert.that((0..10).any({ elem => elem == 5}))
		assert.notThat((0..10).any({ elem => elem == 15}))
		'''.test	
	}

	@Test
	def void all() {
		'''
		var range = 0 .. 10 
		assert.notThat(range.all({ elem => elem.even()}))
		assert.that(range.any({ elem => elem < 11}))
		'''.test	
	}

	@Test
	def void map() {
		'''
		var range = 0 .. 5 
		assert.that([0, 2, 4, 6, 8, 10] == range.map({ elem => elem * 2}))
		'''.test	
	}

	@Test
	def void filter() {
		'''
		const range = 0 .. 10
		const evenFiltered = range.filter({ elem => elem.even() })
		assert.that([0, 2, 4, 6, 8, 10] == evenFiltered)
		'''.test	
	}

	@Test
	def void count() {
		'''
		const range = 0 .. 9
		const evenCount = range.count({ elem => elem.even() })
		assert.equals(5, evenCount)
		'''.test	
	}

	@Test
	def void anyOne() {
		'''
		const range = 0 .. 10
		const anyOne = range.anyOne()
		assert.that(range.contains(anyOne))
		'''.test	
	}

	@Test
	def void min() {
		'''
		const range = -2 .. 10
		const range2 = 7 .. 3
		assert.equals(-2, range.min())
		assert.equals(3, range2.min())
		'''.test	
	}

	@Test
	def void max() {
		'''
		const range = -22 .. -3
		const range2 = 7 .. 3
		assert.equals(-3, range.max())
		assert.equals(7, range2.max())
		'''.test	
	}
	
	@Test
	def void testRangeForDecimalsNotAllowed() {
		'''
		assert.throwsException({ => new Range(2.0, 5.0)})
		'''.test
	}	

	@Test
	def void testRangeForStringsNotAllowed() {
		'''
		assert.throwsException({ => new Range("ABRACADBRA", "PATA")})
		'''.test
	}	

	@Test
	def void find() {
		'''
		const range = 1 .. 9
		const evenFound = range.find({ elem => elem.even() })
		assert.equals(2, evenFound)
		'''.test	
	}

	@Test
	def void findOrValue() {
		'''
		const range = 1 .. 9
		const valueNotFound = range.findOrDefault({ elem => elem > 55 }, 22)
		assert.equals(22, valueNotFound)
		'''.test	
	}

	@Test
	def void findOrElse() {
		'''
		var encontro = true
		const range = 1 .. 9
		const valueNotFound = range.findOrElse({ elem => elem > 55 }, { encontro = false })
		assert.notThat(encontro)
		'''.test	
	}
	
	@Test
	def void sortedBy() {
		'''
		const range = 1 .. 9
		const sortedRange = range.sortedBy({ a, b => a.even() && b.even().negate() })
		assert.equals([2, 4, 6, 8, 1, 3, 5, 7, 9], sortedRange)
		'''.test	
	}

	@Test
	def void sumStep3() {
		'''
		const range = 1 .. 14
		range.step(3)
		assert.equals(35, range.sum())
		'''.test	
	}

	@Test
	def void countStepMinus3() {
		'''
		const range = 8 .. 1
		range.step(-3)
		assert.equals(2, range.count({ elem => elem.even() }))
		'''.test	
	}

	@Test
	def void filterStepMinus3() {
		'''
		const range = 8 .. 1
		range.step(-3)
		assert.equals([8,2], range.filter({ elem => elem.even() }))
		'''.test	
	}

}