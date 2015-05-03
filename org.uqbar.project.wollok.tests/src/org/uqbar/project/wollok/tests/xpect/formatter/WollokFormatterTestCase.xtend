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
import org.uqbar.project.wollok.tests.maven.CustomWollokDslInjectorProvider

/**
 * Tests wollok code formatter
 * 
 * @author jfernandes
 */
@RunWith(XtextRunner)
@InjectWith(CustomWollokDslInjectorProvider)
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
		Assert.assertEquals(expected, formatCode(program));		  
	}
    
    // TEST METHODS

    @Test
    def void testSimpleProgramWithVariablesAndMessageSend() throws Exception {
    	assertFormatting('''program p { val a = 10 val b = 20 this.println(a + b) }''',
        '''
        
        program p {
        	val a = 10
        	val b = 20
        	this.println(a + b)
        }''')
    }
    
    @Test
    def void testClassFormattingOneLineMethodStaysInOneLine() throws Exception {
    	assertFormatting('''class Golondrina { val energia = 10 val kmRecorridos = 0 method comer(gr) { energia = energia + gr } }''',
        '''
        
        class Golondrina {
        	val energia = 10
        	val kmRecorridos = 0
        	method comer(gr) { energia = energia + gr }
        }''')
    }
    
    @Test
    def void testClassFormattingOneLineMethodStaysInNewLine() throws Exception {
    	assertFormatting('''class Golondrina { val energia = 10 val kmRecorridos = 0 method comer(gr) { 
    		energia = energia + gr
    	} }''',
        '''
        
        class Golondrina {
        	val energia = 10
        	val kmRecorridos = 0
        	method comer(gr) {
        		energia = energia + gr
        	}
        }''')
    }
    
    @Test
    def void classFormatting_twolinesBetweenVarsAndMethods() throws Exception {
    	assertFormatting('''class Golondrina { 
    		val energia = 10 
    		val kmRecorridos = 0
    		
    		method comer(gr) { 
    			energia = energia + gr
    		}
    	}''',
        '''
        
        class Golondrina {
        	val energia = 10
        	val kmRecorridos = 0

        	method comer(gr) {
        		energia = energia + gr
        	}
        }''')
    }
    
    @Test
    def void program_ifInline() throws Exception {
    	assertFormatting('''program p { 
    		val a = 10 
    		val b = 0
    		
    		val c = if (a > 0) b else 0
    	}''',
    	'''
        
        program p {
        	val a = 10
        	val b = 0
        
        	val c = if (a > 0) b else 0
        }''')
    }
    
    @Test
    def void program_maxTwoLinBreaksBetweenLines() throws Exception {
    	assertFormatting('''program p { 
    		val a = 10 
    		val b = 0
    		
    		
    		
    		val c = a + b
    	}''',
    	'''
        
        program p {
        	val a = 10
        	val b = 0
        
        	val c = a + b
        }''')
    }
    
    @Test
    def void messageSendParameters() throws Exception {
    	assertFormatting('''program p { 
    		val a = null
    		
    		a . doSomething  ( a, a,    a , a ,  a   )
    	}''',
    	'''
        
        program p {
        	val a = null
        
        	a.doSomething(a, a, a, a, a)
        }''')
    }

	// TODO: test 
	//     	- named objects and object literals
	//		- method parameter declaration
	//		- blocks, parameters, etc

}