package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class DictionaryTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testGetValue() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.put("mario", "5302-6617")
			assert.equals("2142-5980", mapaTelefonos.get("choli"))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testSize() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.put("mario", "5302-6617")
			assert.equals(2, mapaTelefonos.size())
			mapaTelefonos.put("rita", "3923-0029")
			assert.equals(3, mapaTelefonos.size())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testEmptyDictionaryIsEmpty() {
		'''
		program a {
			assert.that((new Dictionary()).isEmpty())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testDictionaryWithElementsIsNotEmpty() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.put("mario", "5302-6617")
			assert.notThat(mapaTelefonos.isEmpty())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testContainsKey() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.put("mario", "5302-6617")
			assert.that(mapaTelefonos.containsKey("choli"))
			assert.notThat(mapaTelefonos.containsKey("cuca"))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testContainsValues() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.put("mario", "5302-6617")
			assert.that(mapaTelefonos.containsValue("2142-5980"))
			assert.notThat(mapaTelefonos.containsValue("2142-5280"))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testRemove() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.put("mario", "5302-6617")
			assert.that(mapaTelefonos.containsKey("choli"))
			mapaTelefonos.remove("choli")
			assert.notThat(mapaTelefonos.containsKey("choli"))	
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testKeys() {
		'''
		program a {
			const mapa = new Dictionary()
			mapa.put(4, "2142-5980")
			mapa.put(9, "5302-6617")
			assert.that(mapa.keys().contains(4))
			assert.that(mapa.keys().contains(9))
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testValues() {
		'''
		program a {
			const mapa = new Dictionary()
			mapa.put("2142-5980", 4)
			mapa.put("5302-6617", 9)
			assert.that(mapa.values().contains(4))
			assert.that(mapa.values().contains(9))
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testContainsForEach() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.put("mario", "5302-6617")
			var result = 0
			mapaTelefonos.forEach({ k, v => result += k.size() + v.size() })
			assert.equals(28, result)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testClearEmptiesADictionary() {
		'''
		program a {
			const mapaTelefonos = new Dictionary()
			mapaTelefonos.put("choli", "2142-5980")
			mapaTelefonos.clear()
			assert.that(mapaTelefonos.isEmpty())
		}
		'''.interpretPropagatingErrors
	}
	
		
}