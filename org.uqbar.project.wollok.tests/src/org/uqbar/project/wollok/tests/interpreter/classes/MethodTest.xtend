package org.uqbar.project.wollok.tests.interpreter.classes

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author jfernandes
 */
class MethodTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void shortSyntaxForMethodsReturningAValue() { '''
		class Golondrina {
			var energia = 100
		
			method energia() = energia
			method capacidadDeVuelo() = 10
		}
		program p {
			val pepona = new Golondrina()
			assert.equals(pepona.energia(), 100)
			assert.equals(pepona.capacidadDeVuelo(), 10)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void varArgsInMethod() { '''
		class Sample {
			method preffix(preffix, numbers...) {
				if (numbers.size() > 0)
					return numbers.map[n| preffix + n]
				else
					return #[]
			}
		}
		test "Var args method must automatically box params as a list" {
			val p = new Sample()
			assert.equals("#1, #2, #3, #4", p.preffix("#", 1, 2, 3, 4).join(", "))
		}
		test "Var args in method with just 1" {
			val p = new Sample()
			assert.equals("#1", p.preffix("#", 1).join(", "))
		}
		
		test "Var args in method without elements" {
			val p = new Sample()
			assert.equals("", p.preffix("#").join(", "))
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void varArgsInConstructor() { '''
		class Sample {
			var result
			new(preffix, numbers...) {
				result = if (numbers.size() > 0) numbers.map[n| preffix + n] else #[]
			}
			method getResult() = result
		}
		test "Var arg in constructor with 4 elements" {
			val p = new Sample("#", 1, 2, 3, 4)
			assert.equals("#1, #2, #3, #4", p.getResult().join(", "))
		}
		test "Var arg in constructor with just 1 element" {
			val p = new Sample("#", 1)
			assert.equals("#1", p.getResult().join(", "))
		}
		test "Var args in method without elements" {
			val p = new Sample("#")
			assert.equals("", p.getResult().join(", "))
		}
		'''.interpretPropagatingErrors
	}
	
}