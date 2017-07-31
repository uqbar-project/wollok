package org.uqbar.project.wollok.tests.xpect.formatter

import com.google.inject.Inject
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.ISerializer
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.interpreter.WollokParseHelper
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

/**
 * Tests wollok code formatter
 * 
 * @author jfernandes
 * @author tesonep
 */
@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
class WollokFormatterTestCase {
	@Inject protected extension WollokParseHelper
	@Inject protected extension ISerializer

	def assertFormatting(String program, String expected) {
		Assert.assertEquals(expected,
        program.parse.serialize(SaveOptions.newBuilder.format().getOptions()))		
	}

	// TEST METHODS
	@Test
	def void testSimpleProgramWithVariablesAndMessageSend() throws Exception {
		assertFormatting('''program p { const a = 10 const b = 20 self.println(a + b) }''', '''
		
		program p {
			const a = 10
			const b = 20
			self.println(a + b)
		}''')
	}

	@Test
	def void testClassFormattingOneLineMethodStaysInOneLine() throws Exception {
		assertFormatting('''class Golondrina { const energia = 10 const kmRecorridos = 0 method comer(gr) { energia = energia + gr } }''', '''
		
		class Golondrina {
			const energia = 10
			const kmRecorridos = 0
			method comer(gr) { energia = energia + gr }
		}''')
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
		}''')
	}

	@Test
	def void classFormatting_twolinesBetweenVarsAndMethods() throws Exception {
		assertFormatting('''class Golondrina { 
    		const energia = 10 
    		const kmRecorridos = 0
    		
    		method comer(gr) { 
    			energia = energia + gr
    		}
    	}''', '''
		
		class Golondrina {
			const energia = 10
			const kmRecorridos = 0
		
			method comer(gr) {
				energia = energia + gr
			}
		}''')
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
		}''')
	}

	@Test
	def void program_maxTwoLinBreaksBetweenLines() throws Exception {
		assertFormatting('''program p { 
    		const a = 10 
    		const b = 0
    		
    		
    		
    		const c = a + b
    	}''', '''
		
		program p {
			const a = 10
			const b = 0
		
			const c = a + b
		}''')
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
			a?.doSomething({ => a.doSomething() })
		}''')
	}

	@Test
	def void constructorDefParametersOnLineConstructorStaysLikeThat() throws Exception {
		assertFormatting('''class Direccion {
	var calle
	var numero  constructor  (  c  ,   n   ) { calle = c numero = n } }''', '''
		
		class Direccion {
			var calle
			var numero
		
			constructor(c, n) { calle = c numero = n }
		}''')
	}

	// I think there's a bug here in the block formatting within the constructor body
	@Test
	def void constructorDefParametersMultipleLinesConstructor() throws Exception {
		assertFormatting('''class Direccion {
	var calle
	var numero  constructor  (  c  ,   n   ) { 
		calle = c
		numero = n
	} }''', '''
		
		class Direccion {
			var calle
			var numero
		
			constructor(c, n) {
				calle = c numero = n
			}
		}''')
	}

	// I think there's a bug here in the block formatting within the constructor body
	@Test
	def void constructorCallParameters() throws Exception {
		assertFormatting('''class Direccion {
	var calle
	var numero  constructor  (  c  ,   n  , b  ,  d ) { calle = c numero = n } }
	class Client {
		method blah() {
			const a = ""
			const b = 2
			const c = new    Direccion  (  a   ,  b   ,  "blah"   ,   [1,2,3]    )
		}
	}''', '''

class Direccion {
	var calle
	var numero

	constructor(c, n, b, d) { calle = c numero = n }
}
class Client {
	method blah() {
		const a = ""
		const b = 2
		const c = new Direccion(a, b, "blah", [ 1, 2, 3 ])
	}
}''')
	}

	@Test
	def void testSimpleTestFormatting() throws Exception {
		assertFormatting(
    	'''test "aSimpleTest"{
    				assert.that(true)
    	}''', '''

test "aSimpleTest" {
	assert.that(true)
}''')
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
		
				console.println("") console.println("")
		
				console.println("")
				console.println("")
			}
		}''')
	}
// TODO: test 
// - named objects and object literals
// - method parameter declaration
// - blocks, parameters, etc
}
