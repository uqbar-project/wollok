package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * @author jfernandes
 */
class ListTestCase extends AbstractWollokInterpreterTestCase {
	
	def instantiateCollectionAsNumbersVariable() {
		"val numbers = #[22, 2, 10]"
	}
	
	def instantiateStrings() {
		"val strings = #['hello', 'hola', 'bonjour', 'ciao', 'hi']"
	}
	
	@Test
	def void min() {
		'''
		program p {
			«instantiateStrings»		
			assert.equals('hi', strings.min[e| e.length() ])
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void max() {
		try 
		'''
		program p {
			«instantiateStrings»
			val r = strings.max[e| e.length() ]	
			assert.equals('bonjour', strings.max[e| e.length() ])
		}'''.interpretPropagatingErrors
		catch (WollokProgramExceptionWrapper e)
					fail(e.message)
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
	def void exists() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.that(numbers.exists[e| e > 20])
			assert.that(numbers.exists[e| e > 0])
			assert.notThat(numbers.exists[e| e < 0])
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
			numbers.forEach([n | sum += n])
			
			assert.equals(34, sum)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void forAll() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.that(numbers.forAll([n | n > 0]))
			assert.notThat(numbers.forAll([n | n > 5]))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void filter() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var greaterThanFiveElements = numbers.filter([n | n > 5])
			assert.that(greaterThanFiveElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void map() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			var halfs = numbers.map([n | n / 2])

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
			var greaterThanFiveElements = numbers.filter[n | n > 5]
			assert.that(greaterThanFiveElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void any() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			val any = numbers.any()
			assert.that(numbers.contains(any))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void equalsWithMethodName() {
		'''
		program p {
			val a = #[23, 2, 1]
			val b = #[23, 2, 1]
			assert.that(a.equals(b))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void equalsWithEqualsEquals() {
		'''
		program p {
			val a = #[23, 2, 1]
			val b = #[23, 2, 1]
			assert.that(a == b)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToString() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals("#[22, 2, 10]", numbers.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToStringWithObjectRedefiningToStringInWollok() {
		'''
		object myObject {
			method internalToSmartString(alreadyShown) = "My Object"
		}
		program p {
			val a = #[23, 2, 1, myObject]
			assert.equals("#[23, 2, 1, My Object]", a.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void detect() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(22, numbers.detect[e| e > 20])
			assert.equals(null, numbers.detect[e| e > 1000])
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void count() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			assert.equals(1, numbers.count[e| e > 20])
			assert.equals(3, numbers.count[e| e > 0])
			assert.equals(0, numbers.count[e| e < 0])
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void sum() {
		'''
		program p {
			«instantiateCollectionAsNumbersVariable»
			
			assert.equals(34, numbers.sum([n | n]))
		}'''.interpretPropagatingErrors
	}
	
}