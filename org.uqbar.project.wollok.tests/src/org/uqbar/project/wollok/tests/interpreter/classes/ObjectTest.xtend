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
			this.assertEquals('hardcoded text', myObject.asText())
		}'''].interpretPropagatingErrors
	}
	
}