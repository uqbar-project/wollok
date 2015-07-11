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
			val helloWorld = [ "helloWorld" ]
			val response = helloWorld.apply()		
			assert.equals("helloWorld", response)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void applyClosureWithOneArgument() {
		'''
		program p {
			val helloWorld = [to | "hello " + to ]
			val response = helloWorld.apply("world")		
			assert.equals("hello world", response)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void closureAccessLocalVariableInProgram() {
		'''
		program p {
			var to = "world"
			val helloWorld = ["hello " + to ]
			
			assert.equals("hello world", helloWorld.apply())
			
			to = "someone else"
			assert.equals("hello someone else", helloWorld.apply())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void closureAsParamToClosure() {
		'''
		program p {
			val twice = [ block | block.apply() + block.apply() ]
			
			assert.equals(4, twice.apply [| 2 ])
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void nestedClosure() {
		'''
		program p {
			val sum =  [a, b | a + b]
			
			val curried = [ a |
				[ b | sum.apply(a, b) ] 
			]
			
			val curriedSum = curried.apply(2)
			
			assert.equals(5, curriedSum.apply(3))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void foldingClosures() {
		'''
		program p {
			val sum2 = [ a | a + 2];
			val by3 = [ b | b * 3];
			val pow = [ c | c ** 2];
			
			val op = #[sum2, by3, pow]
			
			val result = op.fold(0, [acc, o |  o.apply(acc) ])
			
			assert.equals(36, result)
		}'''.interpretPropagatingErrors
	}
	
}