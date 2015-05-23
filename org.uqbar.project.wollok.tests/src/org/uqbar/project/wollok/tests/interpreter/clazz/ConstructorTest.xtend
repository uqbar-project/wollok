package org.uqbar.project.wollok.tests.interpreter.clazz

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.interpreter.WollokInterpreterException

/**
 * 
 * @author jfernandes
 */
class ConstructorTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void defaultConstructor() {
		#['''
		class Point {
			var x
			var y
		}
		''',
		'''
		program t {
			val p1 = new Point()
		}
		'''].interpretPropagatingErrors
	}
	
	@Test
	def void singleSimpleConstructor() {
		#['''
		class C {
			var a = 10
			val b
			var c
			
			new(anA, aB, aC) {
				a = anA
				b = aB
				c = aC
			}
			method getA() { return a }
			method getB() { return b }
			method getC() { return c }
		}
		''',
		'''
		program t {
			val c = new C (1,2,3)
			this.assertEquals(1, c.getA())
			this.assertEquals(2, c.getB())
			this.assertEquals(3, c.getC())
		}
		'''].interpretPropagatingErrors
	}
	
	@Test
	def void multipleConstructors() {
		#['''
		class Point {
			var x
			var y
			
			new () { x = 20 ; y = 20 }
			
			new(ax, ay) {
				x = ax
				y = ay
			}
			method getX() { return x }
			method getY() { return y }
		}
		''',
		'''
		program t {
			val p1 = new Point(1,2)
			this.assertEquals(1, p1.getX())
			this.assertEquals(2, p1.getY())

			val p2 = new Point()
			this.assertEquals(20, p2.getX())
			this.assertEquals(20, p2.getY())
		}
		'''].interpretPropagatingErrors
	}
	
	@Test
	def void wrongNumberOfArgsInConstructorCall() {
		try {
			#['''
			class Point {
				var x
				var y
				
				new(ax, ay) { x = ax ; y = ay }
			}
			''',
			'''
			program t {
				val p1 = new Point()
			}
			'''].interpretPropagatingErrorsWithoutStaticChecks
			fail("Should have failed !!")
		}
		catch (WollokInterpreterException e) {
			assertEquals("No constructor in class Point for parameters []", e.cause.cause.cause.message)
		}
	}
	
}