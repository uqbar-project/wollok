package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * @author jfernandes
 */
class DictionaryTestCase extends AbstractWollokInterpreterTestCase {
	
	def instantiateObjectsDictionary() {
		"val dictionary = {foo:1, bar:'hello', baz: {:}}"
	}
	
	def instantiateNumbersDictionary() {
		"val dictionary = {foo:1, bar:2, baz: 3}"
	}
	
	@Test
	def void min() {
		'''
		program p {
			«instantiateNumbersDictionary»		
			assert.equals(1, dictionary.min {e -> e} )
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void max() {
		try 
		'''
		program p {
			«instantiateNumbersDictionary»
			assert.equals(3, dictionary.max {e -> e} )
		}'''.interpretPropagatingErrors
		catch (WollokProgramExceptionWrapper e)
					fail(e.message)
	}
	
	@Test
	def void size() {
		'''
		program p {
			«instantiateObjectsDictionary»		
			assert.equals(3, dictionary.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void contains() {
		'''
		program p {
			«instantiateNumbersDictionary»
			assert.that(!dictionary.contains(22))
			assert.that(dictionary.contains(1))
		}'''.interpretPropagatingErrors
	}

	@Test
	def void anyWhenTrue() {
		'''
		program p {
			«instantiateObjectsDictionary»
			assert.that(dictionary.any{e-> e == 'hello'})
		}'''.interpretPropagatingErrors
	}

	@Test
	def void anyWhenFalse() {
		'''
		program p {
			«instantiateObjectsDictionary»
			assert.notThat(dictionary.any{e-> e == 0})
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void removeKey() {
		'''
		program p {
			«instantiateObjectsDictionary»
			dictionary.removeKey('hello')		
			assert.that(2 == dictionary.size())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void clear() {
		'''
		program p {
			«instantiateObjectsDictionary»
			dictionary.clear()		
			assert.that(0 == dictionary.size())
			assert.that(dictionary.isEmpty())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void isEmpty() {
		'''
		program p {
			«instantiateNumbersDictionary»
			assert.notThat(dictionary.isEmpty())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void all() {
		'''
		program p {
			«instantiateNumbersDictionary»
			assert.that(dictionary.all {n -> n > 0})
			assert.notThat(dictionary.all {n -> n > 5})
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void filter() {
		'''
		program p {
			«instantiateNumbersDictionary»
			var filtered = dictionary.filter {n -> n > 2}
			assert.that(filtered.size() == 1)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void map() {
		'''
		program p {
			«instantiateNumbersDictionary»
			var succs = dictionary.map {n -> n + 1}

			assert.equals({foo:1, bar:2, baz: 3}, succs)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void shortCutAvoidingParenthesis() {
		'''
		program p {
			«instantiateNumbersDictionary»
			var greaterThanFiveElements = dictionary.filter{n -> n >1 }
			assert.that(greaterThanFiveElements.size() == 2)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void anyOne() {
		'''
		program p {
			«instantiateObjectsDictionary»
			val anyOne = dictionary.anyOne()
			assert.that(dictionary.contains(anyOne))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void equalsWithMethodName() {
		'''
		program p {
			val a = [23, 2, 1]
			val b = [23, 2, 1]
			assert.that(a.equals(b))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void equalsWithEqualsEquals() {
		'''
		program p {
			val a = [23, 2, 1]
			val b = [23, 2, 1]
			assert.that(a == b)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToString() {
		'''
		program p {
			«instantiateNumbersDictionary»
			assert.equals("{foo:1, bar:2, baz: 3}", dictionary.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testToStringWithObjectRedefiningToStringInWollok() {
		'''
		object myObject {
			method internalToSmartString(alreadyShown) = "My Object"
		}
		program p {
			val a = {x: 23, y: myObject}
			assert.equals("{x:23, y:My Object}", a.toString())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void find() {
		'''
		program p {
			«instantiateNumbersDictionary»
			assert.equals(3, dictionary.find{e-> e > 2})
			assert.equals(null, dictionary.find{e-> e > 1000})
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void count() {
		'''
		program p {
			«instantiateNumbersDictionary»
			assert.equals(0, dictionary.count{e-> e > 20})
			assert.equals(1, dictionary.count{e-> e > 2})
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void sum() {
		'''
		program p {
			«instantiateNumbersDictionary»
			
			assert.equals(6, dictionary.sum {n -> n})
		}'''.interpretPropagatingErrors
	}
	
}