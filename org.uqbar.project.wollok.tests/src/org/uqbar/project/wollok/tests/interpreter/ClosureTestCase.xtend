package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

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
	def void closuresWrongArguments() {
		'''
		try {
			{ a => a + 2 }.apply(1, 2)
			assert.fail("Should have failed sending more arguments to a closure")
		} catch e: Exception {
			assert.equals("Wrong number of arguments for closure: expected 1 but you sent 2", e.getMessage())
		}
		'''.test
	}
	
	@Test
	def void closuresWrongArguments2() {
		'''
		try {
			{ a => a + 2 }.apply()
			assert.fail("Should have failed sending more arguments to a closure")
		} catch e: Exception {
			assert.equals("Wrong number of arguments for closure: expected 1 but you sent 0", e.getMessage())
		}
		'''.test
	}

}
