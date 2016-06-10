package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * 
 */
class CollectionTestCase extends AbstractWollokInterpreterTestCase {
	
	def instantiateCollectionAsNumbersVariable() {
		"const numbers = [22, 2, 10]"
	}
	
	def instantiateStrings() {
		"const strings = ['hello', 'hola', 'bonjour', 'ciao', 'hi']"
	}
	
	@Test
	def void min() {
		'''
		program p {
			«instantiateStrings»		
			assert.equals('hi', strings.min{e=> e.length() })
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void minNoArgs() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»		
			assert.equals(2, numbers.min() )
			assert.equals(1, [1].min())
			assert.throwsException({[].min()})
		}'''.interpretPropagatingErrors
	}
		
	@Test
	def void max() {
		try 
		'''
		program p {
			«instantiateStrings»
			const r = strings.max{e=> e.length() }	
			assert.equals('bonjour', strings.max{e=> e.length() })
		}'''.interpretPropagatingErrors
		catch (WollokProgramExceptionWrapper e)
					fail(e.message)
	}
	
	@Test
	def void maxNoArgs() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»		
			assert.equals(22, numbers.max() )
			assert.equals(1, [1].max())
			assert.throwsException({[].max()})
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void size() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»		
			assert.equals(3, numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void contains() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.that(numbers.contains(22))
			assert.that(numbers.contains(2))
			assert.that(numbers.contains(10))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void containsForAListOfWKOs() {
		'''
		object a {}
		object b {}
		object c {}
		object d {}
		program p {
			const l = [a, b, c]
			assert.that(l.contains(a))
			assert.that(l.contains(b))
			assert.that(l.contains(c))
			assert.notThat(l.contains(d))
			assert.notThat(l.contains("hello world"))
			assert.notThat(l.contains(4))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void any() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.that(numbers.any{e=> e > 20})
			assert.that(numbers.any{e=> e > 0})
			assert.notThat(numbers.any{e=> e < 0})
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void remove() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			numbers.remove(22)		
			assert.that(2 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void clear() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			numbers.clear()		
			assert.that(0 == numbers.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void isEmpty() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.notThat(numbers.isEmpty())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void forEach() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			
			var sum = 0
			numbers.forEach({n => sum += n})
			
			assert.equals(34, sum)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void all() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.that(numbers.all({n => n > 0}))
			assert.notThat(numbers.all({n => n > 5}))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void filter() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var greaterThanFiveElements = numbers.filter({n => n > 5})
			assert.that(greaterThanFiveElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void map() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var halfs = numbers.map({n => n / 2})

			assert.equals(3, halfs.size())
			assert.that(halfs.contains(11))
			assert.that(halfs.contains(5))
			assert.that(halfs.contains(1))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void shortCutAvoidingParenthesis() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var greaterThanFiveElements = numbers.filter{n => n > 5}
			assert.that(greaterThanFiveElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void anyOne() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			const anyOne = numbers.anyOne()
			assert.that(numbers.contains(anyOne))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void equalsWithMethodName() {
		'''
		program p {
			const a = [23, 2, 1]
			const b = [23, 2, 1]
			assert.that(a.equals(b))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void equalsWithEqualsEquals() {
		'''
		program p {
			const a = [23, 2, 1]
			const b = [23, 2, 1]
			assert.that(a == b)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToString() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals("[22, 2, 10]", numbers.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToStringWithObjectRedefiningToStringInWollok() {
		'''
		object myObject {
			override method internalToSmartString(alreadyShown) = "My Object"
		}
		program p {
			const a = [23, 2, 1, myObject]
			assert.equals("[23, 2, 1, My Object]", a.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void findWhenElementExists() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(22, numbers.find{e=> e > 20})
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void findOrElse() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(50, numbers.findOrElse({e=> e > 1000}, { 50 }))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void findWhenElementDoesNotExist() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.throwsException { numbers.find{e => e > 1000} }
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void findOrDefaultWhenElementDoesNotExist() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(50, numbers.findOrDefault({e=> e > 1000}, 50))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void findOrDefaultWhenElementExists() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(22, numbers.findOrDefault({e=> e > 20}, 50))
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void count() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(1, numbers.count{e=> e > 20})
			assert.equals(3, numbers.count{e=> e > 0})
			assert.equals(0, numbers.count{e=> e < 0})
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void sum() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			
			assert.equals(34, numbers.sum {n => n})
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void sumNoArgs() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(34, numbers.sum())
			assert.equals(0, [].sum())
			assert.equals(5, [5].sum())
		}'''.interpretPropagatingErrors
	}

}