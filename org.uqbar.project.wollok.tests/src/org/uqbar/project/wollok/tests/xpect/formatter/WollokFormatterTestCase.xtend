package org.uqbar.project.wollok.tests.xpect.formatter

import com.google.common.io.Closer
import com.google.inject.Inject
import com.google.inject.Injector
import java.io.File
import java.io.FileInputStream
import org.eclipse.xtext.formatting.INodeModelFormatter
import org.eclipse.xtext.junit4.AbstractXtextTests
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.WollokDslInjectorProvider

/**
 * Tests wollok code formatter
 * 
 * @author jfernandes
 */
@RunWith(XtextRunner)
@InjectWith(WollokDslInjectorProvider)
class WollokFormatterTestCase extends AbstractXtextTests {
	@Inject
	INodeModelFormatter formatter
	
	@Inject
    Injector injector;

    @Before
    override void setUp() throws Exception {
        super.setUp();
        setInjector(injector);
    }
	
    def String formatted(String path) throws Exception {
        val closer = Closer.create
        try {
            val fis = closer.register(new FileInputStream(new File(path)))
            val rootNode = super.getRootNode(fis)
            val r = formatter.format(rootNode, 0, rootNode.length)
            return r.formattedText
        }
        finally {
            closer.close
        }
    }
    
    def String formatCode(String code) {
        val rootNode = super.getRootNode(code)
        val r = formatter.format(rootNode, 0, rootNode.length)
        r.formattedText
    }
    
   	def assertFormatting(String program, String expected) {
   		println(formatCode(program))
		Assert.assertEquals(expected, formatCode(program));		  
	}
    
    // TEST METHODS

    @Test
    def void testSimpleProgramWithVariablesAndMessageSend() throws Exception {
    	assertFormatting('''program p { const a = 10 const b = 20 this.println(a + b) }''',
        '''
        
        program p {
        	const a = 10
        	const b = 20
        	this.println(a + b)
        }''')
    }
    
    @Test
    def void testClassFormattingOneLineMethodStaysInOneLine() throws Exception {
    	assertFormatting('''class Golondrina { const energia = 10 const kmRecorridos = 0 method comer(gr) { energia = energia + gr } }''',
        '''
        
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
    	} }''',
        '''
        
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
    	}''',
        '''
        
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
    	}''',
    	'''
        
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
    	}''',
    	'''
        
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
    	}''',
    	'''
        
        program p {
        	const a = null
        
        	a.doSomething(a, a, a, a, a)
        }''')
    }
    
    @Test
    def void constructorDefParametersOnLineConstructorStaysLikeThat() throws Exception {
    	assertFormatting('''class Direccion {
	var calle
	var numero  constructor  (  c  ,   n   ) { calle = c numero = n } }''',
        '''
        
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
	} }''',
        '''
        
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
	}''',
        '''

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
    	}''',
'''

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
    			this.bar().bar().bar()
    			
    			console.println("") console.println("")
    			
    			console.println("") 
    			console.println("")
    		}
    	}''', '''
    	
    	object foo {
    		method bar() {
    			this.bar().bar().bar()
    	
    			console.println("") console.println("")
    	
    			console.println("")
    			console.println("")
    		}
    	}''')
    }
	// TODO: test 
	//     	- named objects and object literals
	//		- method parameter declaration
	//		- blocks, parameters, etc

}