package org.uqbar.project.wollok.tests.formatter

import com.google.inject.Inject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.ISerializer
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Assert
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider
import org.uqbar.project.wollok.tests.interpreter.WollokParseHelper
import org.uqbar.project.wollok.wollokDsl.WAssignment

/**
 * Tests wollok code formatter
 * 
 * @author jfernandes
 * @author tesonep
 */
@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
class AbstractWollokFormatterTestCase {
	@Inject protected extension WollokParseHelper
	@Inject protected extension ISerializer

	def assertFormatting(String program, String expected) {
		//program.parse.eContents.show(1)
		Assert.assertEquals(expected,
        program.parse.serialize(SaveOptions.newBuilder.format().getOptions()))		
	}
	
	def void show(EList<EObject> list, int tabs) {
		val indentation = (1..tabs).map [ '  ' ].join
		println(indentation + list.map [ show ])
		list.forEach [ eContents.show(tabs + 1) ]
	}

	def dispatch show(EObject e) {
		e.class.simpleName
	}
	
	def dispatch show(WAssignment a) {
		"Assignment " + a.feature.ref.name
	}
	
	// TEST METHODS
	/**

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
	def void testSimpleProgramWithVariablesAndMessageSend() throws Exception {
		assertFormatting('''program p { const a = 10 const b = 20 self.println(a + b) }''', '''
		program p {
			const a = 10
			const b = 20
			self.println(a + b)
		}
		''')
	}

	@Test
	def void testClassFormattingOneLineMethod() throws Exception {
		assertFormatting('''class    Golondrina {    const    energia      =      10 
		
		
const                  kmRecorridos= 0 method comer(gr) { energia = energia + gr } }''', '''
		class Golondrina {
			const energia = 10
			const kmRecorridos = 0
			method comer(gr) {
				energia = energia + gr
			}
		}
		''')
	}

	@Test
	def void testClassFormattingOneLineMethodStaysInNewLine() throws Exception {
		assertFormatting('''class Golondrina { const energia = 10 const kmRecorridos = 0 method comer(gr) { 
    		energia = energia + gr
    	} }''', '''
		class Golondrina {
			const energia = 10
			const kmRecorridos = 0
			method comer(gr) {
				energia = energia + gr
			}
		}
		''')
	}

	@Test
	def void classFormatting_oneLineBetweenVarsAndMethods() throws Exception {
		assertFormatting('''class Golondrina { 
    		const energia = 10 
    		const kmRecorridos = 0
    		
method comer(gr){energia=energia+gr}}''', '''
		class Golondrina {
			const energia = 10
			const kmRecorridos = 0
			method comer(gr) {
				energia = energia + gr
			}
		}
		''')
	}

	@Test
	def void program_ifInline() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		const c = if (a > 0) b else 0
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = if (a > 0) b else 0
		}
		''')
	}

	@Test
	def void program_ifInlineWithExpressions() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		const c = if (a > 0) b+1 else b-1
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = if (a > 0) b + 1 else b - 1
		}
		''')
	}

	@Test
	def void program_maxOneLineBreakBetweenLines() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		
    		
    		const c = a + b
    	}''', '''
		program p {
			const a = 10
			const b = 0
			const c = a + b
		}
		''')
	}

	@Test
	def void issue702_forEachAndIf() throws Exception {
		assertFormatting('''
		object foo {
		    method bar() {
		        [3,              4        ,50,      100 ].forEach({ it => if (it > 4) { console.println(4) } else {console.println(it)
		            }
		        })
		    }
		}
		''',
		'''
		object foo {
			method bar() {
				[ 3, 4, 50, 100 ].forEach({
					it =>
						if (it > 4) {
							console.println(4)
						} else {
							console.println(it)
						}
				})
			}
		}
		''')
	}
	
	@Test
	def void messageSendParameters() throws Exception {
		assertFormatting('''program p { 
    		const a = null
    		
    		a . doSomething  ( a, a,    a , a ,  a   )
    		a ?. doSomething  ( a, a,    a , a ,  a   )
    		a ?. doSomething  ({=> a .doSomething()})
    	}''', '''
		program p {
			const a = null
			a.doSomething(a, a, a, a, a)
			a?.doSomething(a, a, a, a, a)
			a?.doSomething({
				=>
					a.doSomething()
			})
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
	def void keepNewlinesInSequences() throws Exception {
		assertFormatting(
    	'''
		object foo {
			method bar() {
				self.bar().bar().bar()
				
				console.println("") console.println("")
				
				console.println("") 
				console.println("")
			}
		}''', '''
		object foo {
			method bar() {
				self.bar().bar().bar()
				console.println("")
				console.println("")
				console.println("")
				console.println("")
			}
		}
		''')
	}
	
	@Test
	def void abstractMethods() {
		assertFormatting(
		'''
		class Vehicle {
		    method numberOfPassengers()   method maxSpeed() 
		    method expenseFor100Km() 
		    method efficiency() {
		        return     self.numberOfPassengers() * self.maxSpeed() / self.expenseFor100Km()
		    } 
		}
		''',
		'''
		class Vehicle {
			method numberOfPassengers()
			method maxSpeed()
			method expenseFor100Km()
			method efficiency() {
				return ( self.numberOfPassengers() * self.maxSpeed() ) / self.expenseFor100Km()
			}
		}
		'''
		)
	}
 */
 	
// TODO: test 
// - named objects and object literals
// - method parameter declaration
// - blocks, parameters, etc  */

}
