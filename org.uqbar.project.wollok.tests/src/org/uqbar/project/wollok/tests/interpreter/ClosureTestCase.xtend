package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import junit.framework.Assert

/**
 * @author jfernandes
 */
class ClosureTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void applyNoArgsClosure() {
		'''
		program p {
			const helloWorld = { "helloWorld" }
			const response = helloWorld.apply()
			assert.equals("helloWorld", response)
		}'''.interpretPropagatingErrors
	}

	@Test
	def void applyClosureWithOneArgument() {
		'''
		program p {
			const helloWorld = {to => "hello " + to }
			const response = helloWorld.apply("world")		
			assert.equals("hello world", response)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void closureAccessLocalVariableInProgram() {
		'''
		program p {
			var to = "world"
			const helloWorld = {=>"hello " + to }
			
			assert.equals("hello world", helloWorld.apply())
			
			to = "someone else"
			assert.equals("hello someone else", helloWorld.apply())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void closureAsParamToClosure() {
		'''
		program p {
			const twice = { block => block.apply() + block.apply() }
			
			assert.equals(4, twice.apply {=> 2 })
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void nestedClosure() {
		'''
		program p {
			const sum =  {a, b => a + b}
			
			const curried = { a =>
				{ b => sum.apply(a, b) } 
			}
			
			const curriedSum = curried.apply(2)
			
			assert.equals(5, curriedSum.apply(3))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void foldingClosures() {
		'''
		program p {
			const sum2 = { a => a + 2};
			const by3 = { b => b * 3};
			const pow = { c => c ** 2};
			
			const op = [sum2, by3, pow]
			
			const result = op.fold(0, {acc, o =>  o.apply(acc) })
			
			assert.equals(36, result)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void whileInClosure() {
		Assert.assertEquals("asd", "asdblah")
		'''
		program p {
			var i = 0
			{ i++ }.while { i < 10 } 
			assert.equals(10, i) 
		}'''.interpretPropagatingErrors
	}
	
}