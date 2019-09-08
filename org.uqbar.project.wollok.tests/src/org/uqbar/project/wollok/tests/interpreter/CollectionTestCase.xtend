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

	def instantiateCollectionWithA2() {
		"const collectionWithA2 = [2]"
	}

	def instantiateEmptyCollection() {
		"const emptyCollection = []"
	}
	
	def instantiateStrings() {
		"const strings = ['hello', 'hola', 'bonjour', 'ciao', 'hi']"
	}
	
	@Test
	def void min() {
		'''
		«instantiateStrings»		
		assert.equals('hi', strings.min{e=> e.length() })
		'''.test
	}
	
	@Test
	def void minUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation min doesn't support null parameters", { => [1, 2].min(null) })
		'''.test
	}
	
	
	@Test
	def void minNoArgs() {
		'''
		«instantiateCollectionAsNumbersVariable»		
		assert.equals(2, numbers.min() )
		assert.equals(1, [1].min())
		assert.throwsException({[].min()})
		'''.test
	}
	
	@Test
	def void minIfEmpty() {
		'''
		«instantiateStrings»
		assert.equals('hi', strings.minIfEmpty({ e => e.length() }, { 'lista vacia' }))
		assert.equals('lista vacia', [].minIfEmpty({ e => e.length() }, { 'lista vacia' }))
		'''.test
	}
	
	@Test
	def void minIfEmptyUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation minIfEmpty doesn't support null parameters", { => [1, 2].minIfEmpty(null) })
		'''.test
	}
	
	@Test
	def void minIfEmptyNoArgs() {
		'''
		assert.equals(1, [3,1,2].minIfEmpty({ 99 }))
		assert.equals(99, [].minIfEmpty({ 99 }))
		'''.test
	}
		
	@Test
	def void max() {
		try 
		'''
		«instantiateStrings»
		const r = strings.max{e=> e.length() }	
		assert.equals('bonjour', strings.max{e=> e.length() })
		'''.test
		catch (WollokProgramExceptionWrapper e)
					fail(e.message)
	}

	@Test
	def void maxUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation max doesn't support null parameters", { => [1, 2].max(null) })
		'''.test
	}
	
	@Test
	def void maxNoArgs() {
		'''
		«instantiateCollectionAsNumbersVariable»		
		assert.equals(22, numbers.max() )
		assert.equals(1, [1].max())
		assert.throwsException({[].max()})
		'''.test
	}
	
	@Test
	def void maxIfEmpty() {
		'''
		«instantiateStrings»
		assert.equals('bonjour', strings.maxIfEmpty({ e => e.length() }, { 'lista vacia' }))
		assert.equals('lista vacia', [].maxIfEmpty({ e => e.length() }, { 'lista vacia' }))
		'''.test
	}
	
	@Test
	def void maxIfEmptyUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation maxIfEmpty doesn't support null parameters", { => [1, 2].maxIfEmpty(null) })
		'''.test
	}
	
	@Test
	def void maxIfEmptyNoArgs() {
		'''
		assert.equals(3, [1,3,2].maxIfEmpty({ 99 }))
		assert.equals(99, [].maxIfEmpty({ 99 }))
		'''.test
	}
	
	@Test
	def void size() {
		'''
		«instantiateCollectionAsNumbersVariable»		
		assert.equals(3, numbers.size())
		'''.test
	}
	
	@Test
	def void contains() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.that(numbers.contains(22))
		assert.that(numbers.contains(2))
		assert.that(numbers.contains(10))
		'''.test
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
	def void unique() {
		'''
		assert.equals(1, [1].unique())
		'''.test
	}

	@Test
	def void uniqueWithEmptyCollection() {
		'''
		assert.throwsExceptionWithMessage("Illegal operation 'unique' on empty collection", { => [].unique() })
		'''.test
	}	

	@Test
	def void uniqueWithManyElements() {
		'''
		assert.throwsExceptionWithMessage("Illegal operation 'unique' on collection with 2 elements", { => [1, 2].unique() })
		'''.test
	}

	@Test
	def void anyUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation any doesn't support null parameters", { => [1, 2].any(null) })
		'''.test
	}
	
	@Test
	def void any() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.that(numbers.any{e=> e > 20})
		assert.that(numbers.any{e=> e > 0})
		assert.notThat(numbers.any{e=> e < 0})
		'''.test
	}
	
	@Test
	def void remove() {
		'''
		«instantiateCollectionAsNumbersVariable»
		numbers.remove(22)
		assert.that(2 == numbers.size())
		'''.test
	}
	
	@Test
	def void clear() {
		'''
		«instantiateCollectionAsNumbersVariable»
		numbers.clear()
		assert.that(0 == numbers.size())
		'''.test
	}
	
	@Test
	def void isEmpty() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.notThat(numbers.isEmpty())
		'''.test
	}
	
	@Test
	def void forEachUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation forEach doesn't support null parameters", { => [1, 2].forEach(null) })
		'''.test
	}
	
	@Test
	def void forEach() {
		'''
		«instantiateCollectionAsNumbersVariable»
		
		var sum = 0
		numbers.forEach({n => sum += n})
		
		assert.equals(34, sum)
		'''.test
	}
	
	@Test
	def void allUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation all doesn't support null parameters", { => [1, 2].all(null) })
		'''.test
	}
	
	@Test
	def void all() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.that(numbers.all({n => n > 0}))
		assert.notThat(numbers.all({n => n > 5}))
		'''.test
	}
	
	@Test
	def void filterUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation filter doesn't support null parameters", { => [1, 2].filter(null) })
		'''.test
	}
	
	@Test
	def void filter() {
		'''
		«instantiateCollectionAsNumbersVariable»
		var greaterThanFiveElements = numbers.filter({n => n > 5})
		assert.that(greaterThanFiveElements.size() == 2)
		'''.test
	}
	
	@Test
	def void mapUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation map doesn't support null parameters", { => [1, 2].map(null) })
		'''.test
	}
	
	@Test
	def void map() {
		'''
		«instantiateCollectionAsNumbersVariable»
		var halfs = numbers.map({n => n / 2})

		assert.equals(3, halfs.size())
		assert.that(halfs.contains(11))
		assert.that(halfs.contains(5))
		assert.that(halfs.contains(1))
		'''.test
	}
	
	@Test
	def void mapReturnsList() {
		'''
		const evens = #{1,2,3}.map({n => n.even()})

		assert.equals(3, evens.size())
		assert.equals(1, evens.occurrencesOf(true))
		assert.equals(2, evens.occurrencesOf(false))
		'''.test
	}
		
	@Test
	def void shortCutAvoidingParenthesis() {
		'''
		«instantiateCollectionAsNumbersVariable»
		var greaterThanFiveElements = numbers.filter{n => n > 5}
		assert.that(greaterThanFiveElements.size() == 2)
		'''.test
	}
	
	@Test
	def void anyOne() {
		'''
		«instantiateCollectionAsNumbersVariable»
		const anyOne = numbers.anyOne()
		assert.that(numbers.contains(anyOne))
		'''.test
	}
	
	@Test
	def void equalsWithMethodName() {
		'''
		const a = [23, 2, 1]
		const b = [23, 2, 1]
		assert.that(a.equals(b))
		'''.test
	}
	
	@Test
	def void equalsWithEqualsEquals() {
		'''
		const a = [23, 2, 1]
		const b = [23, 2, 1]
		assert.that(a == b)
		'''.test
	}
	
	@Test
	def void testToString() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals("[22, 2, 10]", numbers.toString())
		'''.test
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
		«instantiateCollectionAsNumbersVariable»
		assert.equals(22, numbers.find{e=> e > 20})
		'''.test
	}
	
	@Test
	def void findOrElse() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals(50, numbers.findOrElse({e=> e > 1000}, { 50 }))
		'''.test
	}

	@Test
	def void findWhenElementDoesNotExist() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.throwsException { numbers.find{e => e > 1000} }
		'''.test
	}
	
	@Test
	def void findOrDefaultWhenElementDoesNotExist() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals(50, numbers.findOrDefault({e=> e > 1000}, 50))
		'''.test
	}

	@Test
	def void findOrDefaultWhenElementExists() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals(22, numbers.findOrDefault({e=> e > 20}, 50))
		'''.test
	}
	
	@Test
	def void countUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation count doesn't support null parameters", { => [1, 2].count(null) })
		'''.test
	}
	
	@Test
	def void count() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals(1, numbers.count{e=> e > 20})
		assert.equals(3, numbers.count{e=> e > 0})
		assert.equals(0, numbers.count{e=> e < 0})
		'''.test
	}
	
	@Test
	def void sumUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation sum doesn't support null parameters", { => [1, 2].sum(null) })
		'''.test
	}
	
	@Test
	def void sum() {
		'''
		«instantiateCollectionAsNumbersVariable»
		
		assert.equals(34, numbers.sum {n => n})
		'''.test
	}

	@Test
	def void concatenation() {
		'''
		const lista1 = [1, 4]
		const lista2 = [2, 7]
		const lista3 = lista1 + lista2
		assert.equals([1, 4], lista1)
		assert.equals([1, 4, 2, 7], lista3)
		'''.test
	}
	
	@Test
	def void sumNoArgsWithManyElements() {
		'''
		«instantiateCollectionAsNumbersVariable»
		assert.equals(34, numbers.sum())
		'''.test
	}

	@Test
	def void sumNoArgsWithNoElementsSucceeds() {
		'''
		assert.equals(0, [].sum())
		'''.test
	}

			
	@Test
	def void sumNoArgsWithSingleElement() {
		'''
		assert.equals(5, [5].sum())
		'''.test
	}					
	
	@Test
	def void occurrencesOfInEmptyCollectionIsZero() {
		'''
		assert.equals(0, [].occurrencesOf(4))
		'''.test
	}
	
	@Test
	def void occurrencesOfInSingleElementCollection() {
		'''
		assert.equals(1, [4].occurrencesOf(4))
		assert.equals(0, [4].occurrencesOf('Hola'))
		'''.test
	}
	
	@Test
	def void occurrencesOfInMultiElementCollection() {
		'''
		assert.equals(3, [1, 2, 3, 4, 4, 1, 2, 4, 0].occurrencesOf(4))
		assert.equals(1, [1, 'Hola', 'mundo'].occurrencesOf('Hola'))
		assert.equals(1, #{'Hola', 'mundo', 4, 4}.occurrencesOf(4))
		'''.test
	}
	
	@Test
	def void occurrencesOfInSetsNotGreaterThanOne() {
		'''
		assert.equals(1, #{'Hola', 3.0, 4, 4}.occurrencesOf(4))
		'''.test
	}

	@Test
	def void lastWithNoElementsFails() {
		'''
		assert.throwsException({ [].last() })
		'''.test
	}

	@Test
	def void lastWithSingleElementSucceeds() {
		'''
		assert.equals('Hola', ['Hola'].last())
		'''.test
	}

	@Test
	def void lastWithManyElementsSucceeds() {
		'''
		assert.equals(4, [1, 2, 3, 4].last())
		'''.test
	}
	
	@Test
	def void removeAll() {
		'''
		«instantiateCollectionAsNumbersVariable»
		numbers.removeAll(numbers.drop(1))
		assert.equals([numbers.head()], numbers)
		'''.test
	}
	
	@Test
	def void removeAllSuchThat() {
		'''
		«instantiateCollectionAsNumbersVariable»
		«instantiateCollectionWithA2»
		«instantiateEmptyCollection»
		numbers.removeAllSuchThat({it => it >= 10})
		assert.equals(collectionWithA2, numbers)
		numbers.removeAllSuchThat({it => it.odd()})
		assert.equals(collectionWithA2, numbers)
		numbers.removeAllSuchThat({it => it.even()})
		assert.equals(emptyCollection, numbers)
		numbers.removeAllSuchThat({it => it.even()})
		assert.equals(emptyCollection, numbers)
		'''.test
	}

	@Test
	def void removeOnIteration() {
		'''
		«instantiateCollectionAsNumbersVariable»
		
		numbers.forEach({n => numbers.remove(n)})
		assert.that(numbers.isEmpty())
		
		'''.test
	}
		@Test
	
	def void addOnIteration() {
		'''
		«instantiateCollectionAsNumbersVariable»
		
		numbers.forEach({n => numbers.add(n * 2)})
		assert.that(numbers.contains(2))
		assert.that(numbers.contains(22))
		assert.that(numbers.contains(10))
		assert.that(numbers.contains(44))
		assert.that(numbers.contains(4))		
		assert.that(numbers.contains(20))
		'''.test
	}
	
	@Test
	def void sortedBy() {
		'''
		«instantiateCollectionAsNumbersVariable»
		var numbersSet = numbers.asSet()
		assert.equals([22,10,2], numbers.sortedBy({a,b=>a>b}))
		assert.equals([22,10,2], numbersSet.sortedBy({a,b=>a>b}))
		assert.equals([2,10,22], numbers.sortedBy({a,b=>a<b}))
		assert.equals([2,10,22], numbersSet.sortedBy({a,b=>a<b}))
		assert.equals([5], [5].sortedBy({a,b=>a>b}))
		assert.equals([5], #{5}.sortedBy({a,b=>a>b}))
		assert.equals([], [].sortedBy({a,b=>a>b}))
		
		'''.test
	}	

	
}
