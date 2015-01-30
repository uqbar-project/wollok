package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author jfernandes
 */
class ClosureTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void applyNoArgsClosure() {
		'''
		program p {
			val helloWorld = [ "helloWorld" ]
			val response = helloWorld.apply()		
			this.assertEquals("helloWorld", response)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void applyClosureWithOneArgument() {
		'''
		program p {
			val helloWorld = [to | "hello " + to ]
			val response = helloWorld.apply("world")		
			this.assertEquals("hello world", response)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void closureAccessLocalVariableInProgram() {
		'''
		program p {
			var to = "world"
			val helloWorld = ["hello " + to ]
			
			this.assertEquals("hello world", helloWorld.apply())
			
			to = "someone else"
			this.assertEquals("hello someone else", helloWorld.apply())
		}'''.interpretPropagatingErrors
	}
	
}