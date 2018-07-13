package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class DictionaryTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testGetValue() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		assert.equals("2142-5980", mapaTelefonos.get("choli"))
		'''.test
	}

	@Test
	def void testGetValueNotFound() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		assert.throwsException({ => mapaTelefonos.get("betty") })
		'''.test
	}

	@Test
	def void testGetOrElseForValueNotFound() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		var notFound = false
		mapaTelefonos.getOrElse("betty", { => notFound = true } )
		assert.that(notFound)
		'''.test
	}

	@Test
	def void testSize() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		assert.equals(2, mapaTelefonos.size())
		mapaTelefonos.put("rita", "3923-0029")
		assert.equals(3, mapaTelefonos.size())
		'''.test
	}

	@Test
	def void testEmptyDictionaryIsEmpty() {
		'''
		assert.that((new Dictionary()).isEmpty())
		'''.test
	}

	@Test
	def void testDictionaryWithElementsIsNotEmpty() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		assert.notThat(mapaTelefonos.isEmpty())
		'''.test
	}

	@Test
	def void testContainsKey() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		assert.that(mapaTelefonos.containsKey("choli"))
		assert.notThat(mapaTelefonos.containsKey("cuca"))
		'''.test
	}

	@Test
	def void testContainsValues() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		assert.that(mapaTelefonos.containsValue("2142-5980"))
		assert.notThat(mapaTelefonos.containsValue("2142-5280"))
		'''.test
	}

	@Test
	def void testRemove() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		assert.that(mapaTelefonos.containsKey("choli"))
		mapaTelefonos.remove("choli")
		assert.notThat(mapaTelefonos.containsKey("choli"))
		'''.test
	}

	@Test
	def void testRemoveNonExistentKey() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		mapaTelefonos.remove("pepe")
		assert.equals(2, mapaTelefonos.size())
		'''.test
	}
	
	@Test
	def void testKeys() {
		'''
		const mapa = new Dictionary()
		mapa.put(4, "2142-5980")
		mapa.put(9, "5302-6617")
		assert.that(mapa.keys().contains(4))
		assert.that(mapa.keys().contains(9))
		'''.test
	}
	
	@Test
	def void testValues() {
		'''
		const mapa = new Dictionary()
		mapa.put("2142-5980", 4)
		mapa.put("5302-6617", 9)
		assert.that(mapa.values().contains(4))
		assert.that(mapa.values().contains(9))
		'''.test
	}
	
	@Test
	def void testContainsForEach() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.put("mario", "5302-6617")
		var result = 0
		mapaTelefonos.forEach({ k, v => result += k.size() + v.size() })
		assert.equals(28, result)
		'''.test
	}

	@Test
	def void testClearEmptiesADictionary() {
		'''
		const mapaTelefonos = new Dictionary()
		mapaTelefonos.put("choli", "2142-5980")
		mapaTelefonos.clear()
		assert.that(mapaTelefonos.isEmpty())
		'''.test
	}

	@Test
	def void testToString() {
		'''
		const mapaTelefonos = new Dictionary()
		assert.equals(mapaTelefonos.toString(), "a Dictionary []")
		mapaTelefonos.put("choli", "2142-5980")
		assert.equals(mapaTelefonos.toString(), "a Dictionary [\"choli\" -> \"2142-5980\"]")
		mapaTelefonos.put(2, 33)
		assert.equals(mapaTelefonos.toString(), "a Dictionary [2 -> 33, \"choli\" -> \"2142-5980\"]")
		'''.test
	}
	
	@Test
	def void testPutNullKeyShouldThrowAnException() {
		'''
		assert.throwsExceptionWithMessage("You cannot add an element with a null key in a Dictionary", { new Dictionary().put(null, 2184) })
		'''.test		
	}
	
	@Test
	def void testPutNullValueShouldThrowAnException() {
		'''
		assert.throwsExceptionWithMessage("You cannot add a null value in a Dictionary", { new Dictionary().put(2145, null) })
		'''.test		
	}
	
	@Test
	def void addingSeveralSwallowsInAMap() {
		'''
		class Golondrina { }
		
		program a {
			var pepa = new Golondrina()
			var s = new Dictionary()
			s.put(pepa, 0)
			
			(1..100).forEach({i => s.put(new Golondrina(), i)}) // all objects are not == to pepa
			
			assert.notEquals(pepa, new Golondrina())
			assert.equals(101, s.size())
			assert.equals(0, s.get(pepa))
		}
		'''.interpretPropagatingErrors
	}		
	
}