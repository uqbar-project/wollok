package org.uqbar.project.wollok.tests.formatter

import org.junit.Test

class ConstructorsFormatterTestCase extends AbstractWollokFormatterTestCase {
	
	@Test
	def void testSeveralVariableDefinitionsToConstantsInConstructor() throws Exception {
		assertFormatting(
		'''class Foo {
			var x
			var y
		
			constructor(anX, anY) {	x = 2 y = 3	}
		}''', 
		'''
		class Foo {
		
			var x
			var y
		
			constructor(anX, anY) {
				x = 2
				y = 3
			}
		
		}
		
		''')
	}

	@Test
	def void testSeveralVariableDefinitionsToVariablesInConstructor() throws Exception {
		assertFormatting(
		'''class Foo {
			var x
			var y
		
			constructor(anX, anY) {
				x = anX
				y = anY
			}
		}''', 
		'''
		class Foo {
		
			var x
			var y
		
			constructor(anX, anY) {
				x = anX
				y = anY
			}
		
		}
		
		''')
	}
	
	@Test
	def void constructorDefParametersOnLineConstructorStaysLikeThat() throws Exception {
		assertFormatting('''class Direccion {
	var calle
	var numero  constructor  (  c  ,   n   ) { calle = c numero = n } }''', '''
		class Direccion {
		
			var calle
			var numero
		
			constructor(c, n) {
				calle = c
				numero = n
			}
		
		}
		
		''')
	}

	@Test
	def void constructorDefParametersMultipleLinesConstructor() throws Exception {
		assertFormatting('''class         Direccion            
{
	var calle var numero  constructor  (  c  ,   n   ) 
{ 
		calle = c
		numero = n
	} }''', '''
		class Direccion {
		
			var calle
			var numero
		
			constructor(c, n) {
				calle = c
				numero = n
			}
		
		}
		
		''')
	}

	@Test
	def void constructorCallParameters() throws Exception {
		assertFormatting('''class Direccion {
	var calle
	var numero  constructor  (  c  ,   n  , b  ,  d ) { calle = c numero = n } }
	class Client {
		method blah() {
			const a = "" const b = 2
			const c = new    Direccion  (  a   ,  b   ,  "blah"   ,   [1,2,3]    )
		}
	}''', '''
	class Direccion {
	
		var calle
		var numero
	
		constructor(c, n, b, d) {
			calle = c
			numero = n
		}
	
	}
	
	class Client {
	
		method blah() {
			const a = ""
			const b = 2
			const c = new Direccion(a, b, "blah", [ 1, 2, 3 ])
		}
	
	}
	
	''')
	}
	
}