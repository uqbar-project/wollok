package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
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

	@Test
	def void constructorSelfDelegation() throws Exception {
		assertFormatting('''
		class A { var a constructor(_a) { a = _a } 
		
		
		constructor(_a, _b)   =           self         
		
		
		(a                 +
		
		b)}
		
		
		
		''', 
		'''
		class A {
		
			var a
		
			constructor(_a) {
				a = _a
			}
		
			constructor(_a, _b) = self(a + b)
		
		}
		
		''')
	}
	
	@Test
	def void constructorSuperDelegation() throws Exception {
		assertFormatting('''
		class A { var a constructor(_a) { a = _a } 
		}
		class B {
		
		constructor(_a, _b)   =           super         
		
		
		(a                 +
		
		b)}
		
		
		
		''', 
		'''
		class A {
		
			var a
		
			constructor(_a) {
				a = _a
			}
		
		}
		
		class B {
		
			constructor(_a, _b) = super(a + b)
		
		}
		
		''')
	}
	
		@Test
	def void constructorCallFormatting() throws Exception {
		assertFormatting('''
		class A { var a
		var b = 2 var c var d 
		}
		class B {
			
		method buildA() {
		new A(                     a
		
		
		 = 
		 
		 200			
		,
		b                = "Hello"
		
		,
		
		c =               new        Date()    
		
		, d=#{1   , 8} )	
		}
		''', 
		'''
		class A {
		
			var a
			var b = 2
			var c
			var d
		
		}
		
		class B {
		
			method buildA() {
				new A(a = 200, b = "Hello", c = new Date(), d = #{ 1, 8 })
			}
		
		}
		
		''')
	}
}