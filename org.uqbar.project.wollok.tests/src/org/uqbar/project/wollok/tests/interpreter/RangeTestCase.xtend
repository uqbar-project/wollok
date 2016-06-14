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
		program a {
			const range = 0 .. 10
			var sum = 0
			assert.that(range != null)
			range.forEach { i => sum += i }
			assert.equals(55, sum)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void fold() {
		'''
		program a {
			var range = 0 .. 10 
			var sum = range.fold(0, { acum, each => acum + each })
			assert.equals(55, sum)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void sum() {
		'''
		program a {
			var range = 0 .. 9 
			assert.equals(45, range.sum())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void sumClosure() {
		'''
		program a {
			var range = 0 .. 9 
			assert.equals(90, range.sum({ n => n * 2 }))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void contains() {
		'''
		program a {
			var range = 0 .. 9 
			assert.that(range.contains(9))
			assert.that(range.contains(0))
			assert.that(range.contains(4))
			assert.notThat(range.contains(-1))
			assert.notThat(range.contains(10))
		}
		'''.interpretPropagatingErrors
	}
		
	@Test
	def void size() {
		'''
		program a {
			var range = 0 .. 10 
			assert.equals(11, range.size())
			assert.equals(10, (12..21).size())
			assert.equals(7, (-3..3).size())
		}
		'''.interpretPropagatingErrors
	
	}
	
	@Test
	def void isEmpty() {
		'''
		program a {
			var range = 0 .. 10 
			assert.notThat(range.isEmpty())
			assert.notThat((0 .. 0).isEmpty())
		}
		'''.interpretPropagatingErrors
	
	}
	
	@Test
	def void any() {
		'''
		program a {
			var range = 0 .. 10 
			assert.that(range.any({ elem => elem == 5}))
			assert.notThat(range.any({ elem => elem == 15}))
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void all() {
		'''
		program a {
			var range = 0 .. 10 
			assert.notThat(range.all({ elem => elem.even()}))
			assert.that(range.any({ elem => elem < 11}))
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void map() {
		'''
		program a {
			var range = 0 .. 5 
			assert.that([0, 2, 4, 6, 8, 10] == range.map({ elem => elem * 2}))
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void filter() {
		'''
		program a {
			const range = 0 .. 10
			const evenFiltered = range.filter({ elem => elem.even() })
			assert.that([0, 2, 4, 6, 8, 10] == evenFiltered)
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void count() {
		'''
		program a {
			const range = 0 .. 9
			const evenCount = range.count({ elem => elem.even() })
			assert.equals(5, evenCount)
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void anyOne() {
		'''
		program a {
			const range = 0 .. 10
			const anyOne = range.anyOne()
			assert.that(range.contains(anyOne))
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void min() {
		'''
		program a {
			const range = -2 .. 10
			const range2 = 7 .. 3
			assert.equals(-2, range.min())
			assert.equals(3, range2.min())
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void max() {
		'''
		program a {
			const range = -22 .. -3
			const range2 = 7 .. 3
			assert.equals(-3, range.max())
			assert.equals(7, range2.max())
		}
		'''.interpretPropagatingErrors	
	}
	
	@Test
	def void testRangeForDecimalsNotAllowed() {
		'''
		program a {
			assert.throwsException({ => new Range(2.0, 5.0)})
		}
		'''.interpretPropagatingErrors
	}	

	@Test
	def void testRangeForStringsNotAllowed() {
		'''
		program a {
			assert.throwsException({ => new Range("ABRACADBRA", "PATA")})
		}
		'''.interpretPropagatingErrors
	}	

	@Test
	def void find() {
		'''
		program a {
			const range = 1 .. 9
			const evenFound = range.find({ elem => elem.even() })
			assert.equals(2, evenFound)
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void findOrValue() {
		'''
		program a {
			const range = 1 .. 9
			const valueNotFound = range.findOrDefault({ elem => elem > 55 }, 22)
			assert.equals(22, valueNotFound)
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void findOrElse() {
		'''
		program a {
			var encontro = true
			const range = 1 .. 9
			const valueNotFound = range.findOrElse({ elem => elem > 55 }, { encontro = false })
			assert.notThat(encontro)
		}
		'''.interpretPropagatingErrors	
	}
	
	@Test
	def void sortedBy() {
		'''
		program a {
			const range = 1 .. 9
			const sortedRange = range.sortedBy({ a, b => a.even() && b.even().negate() })
			assert.equals([2, 4, 6, 8, 1, 3, 5, 7, 9], sortedRange)
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void sumStep3() {
		'''
		program a {
			const range = 1 .. 14
			range.step(3)
			assert.equals(35, range.sum())
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void countStepMinus3() {
		'''
		program a {
			const range = 8 .. 1
			range.step(-3)
			assert.equals(2, range.count({ elem => elem.even() }))
		}
		'''.interpretPropagatingErrors	
	}

	@Test
	def void filterStepMinus3() {
		'''
		program a {
			const range = 8 .. 1
			range.step(-3)
			assert.equals([8,2], range.filter({ elem => elem.even() }))
		}
		'''.interpretPropagatingErrors	
	}

}