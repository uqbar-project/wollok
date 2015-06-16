package org.uqbar.project.wollok.tests.interpreter.classes

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Tests automatic inheritance of wollok Object class
 * 
 * @author jfernandes
 */
class ObjectTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testSimpleMethodInheritedFromObject() {
		#['''
		class MyClass {
		}
		''',
		'''
		program p {
			val myObject = new MyClass()
			this.assert(myObject.identity() != null)
		}'''].interpretPropagatingErrors
	}
	
	@Test
	def void testInheritedMethodForPairLiterals() {
		#['''
		class MyClass {
		}
		''',
		'''
		program p {
			val myObject = new MyClass()
			val pair = myObject -> 23
			
			this.assertEquals(myObject, pair.getX())
			this.assertEquals(23, pair.getY())
		}'''].interpretPropagatingErrors
	}
	
}