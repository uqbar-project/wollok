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
	def void flatMap() { 
		'''
		var range = 1 .. 4 
		var flatMap = range.flatMap { n => 1 .. n }
		assert.equals([1, 1, 2, 1, 2, 3, 1, 2, 3, 4], flatMap)
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
	def void anyOneProbability() {
		'''
		const range = 0 .. 10
		range.step(2)
		const counter = new Dictionary()
		range.forEach({n => counter.put(n,0)})
		5000.times({ i =>
			var n = range.anyOne()
			var c = counter.get(n) + 1
			counter.put(n,c)
		})
		range.forEach({n => assert.that(counter.get(n) > 500)})
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
		const range = new Range(2.4, 5.7)
		assert.equals([2, 3, 4, 5], range.asList())
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

	@Test
 	def void testRangeForDecimalsIfIntegersAreAllowed() {
 		'''
		const range = new Range(2.0, 5.0)
		assert.equals(5, range.max())
 		'''.test
 	}
 
 	@Test
	def void rangeWithNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation .. doesn't support null parameters", { => 1..null })
		'''.test
	}
 
  	@Test
	def void forEachUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation forEach doesn't support null parameters", { => (1..4).forEach(null) })
		'''.test
	}
	
  	@Test
	def void filterUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation filter doesn't support null parameters", { => (1..4).filter(null) })
		'''.test
	}

  	@Test
	def void mapUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation map doesn't support null parameters", { => (1..4).map(null) })
		'''.test
	}
	
  	@Test
	def void anyUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation any doesn't support null parameters", { => (1..4).any(null) })
		'''.test
	}
 	
}