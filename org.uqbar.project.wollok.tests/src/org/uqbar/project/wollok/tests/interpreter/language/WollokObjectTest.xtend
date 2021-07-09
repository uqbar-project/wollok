package org.uqbar.project.wollok.tests.interpreter.language

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

class WollokObjectTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testUnderstand() {
		'''
		object myObject {
			
			var privateVar = "private"
			var property aVarProperty = "writable"
			const property aConstProperty = "readOnly"
			
			method aGetter() {
				return "foo"
			}
			
			method aSetter(foo) {
				
			}
			
			method aMethod(foo, bar) {
				
			}				
		}

		//A program is necessary in order to evaluate and create the WollokObject
		program abc {
			myObject
		}
		'''.interpretPropagatingErrors
			
		val myWollokObject = "myObject".asWollokObject

		myWollokObject.assertProperties
		myWollokObject.assertVarProperties
		myWollokObject.assertConstantProperties
		myWollokObject.assertUnderstands

	}

	def assertUnderstands(WollokObject myWollokObject) {
		val zeroParams = #[] as WollokObject[]		
		val oneParam = #[myWollokObject] as WollokObject[]
		val twoParams = #[myWollokObject , myWollokObject] as WollokObject[]
		
		assertFalse(myWollokObject.understands("privateVar", zeroParams))
		assertFalse(myWollokObject.understands("privateVar", oneParam))
		assertFalse(myWollokObject.understands("privateVar", twoParams))
		
		assertTrue(myWollokObject.understands("aVarProperty", zeroParams))
		assertTrue(myWollokObject.understands("aVarProperty", oneParam))	
		assertFalse(myWollokObject.understands("aVarProperty", twoParams))	
			
		assertTrue(myWollokObject.understands("aConstProperty", zeroParams))
		assertFalse(myWollokObject.understands("aConstProperty", oneParam))
		assertFalse(myWollokObject.understands("aConstProperty", twoParams))
		
		assertTrue(myWollokObject.understands("aGetter", zeroParams))
		assertFalse(myWollokObject.understands("aGetter", oneParam))
		assertFalse(myWollokObject.understands("aGetter", twoParams))
		
		assertFalse(myWollokObject.understands("aSetter", zeroParams))
		assertTrue(myWollokObject.understands("aSetter", oneParam))
		assertFalse(myWollokObject.understands("aSetter", twoParams))

		assertFalse(myWollokObject.understands("aMethod", zeroParams))
		assertFalse(myWollokObject.understands("aMethod", oneParam))
		assertTrue(myWollokObject.understands("aMethod", twoParams))

		assertFalse(myWollokObject.understands("nonExistent", zeroParams))
		assertFalse(myWollokObject.understands("nonExistent", oneParam))
		assertFalse(myWollokObject.understands("nonExistent", twoParams))		
	}
	
	def assertConstantProperties(WollokObject myWollokObject) {
		assertFalse(myWollokObject.hasConstantProperty("privateVar"))
		assertFalse(myWollokObject.hasConstantProperty("aVarProperty"))
		assertTrue(myWollokObject.hasConstantProperty("aConstProperty"))
		assertFalse(myWollokObject.hasConstantProperty("aGetter"))
		assertFalse(myWollokObject.hasConstantProperty("aSetter"))
		assertFalse(myWollokObject.hasConstantProperty("aMetthod"))
		assertFalse(myWollokObject.hasConstantProperty("nonExistent"))		
	}
	
	def assertVarProperties(WollokObject myWollokObject) {
		assertFalse(myWollokObject.hasVarProperty("privateVar"))
		assertTrue(myWollokObject.hasVarProperty("aVarProperty"))
		assertFalse(myWollokObject.hasVarProperty("aConstProperty"))
		assertFalse(myWollokObject.hasVarProperty("aGetter"))
		assertFalse(myWollokObject.hasVarProperty("aSetter"))
		assertFalse(myWollokObject.hasVarProperty("aMetthod"))
		assertFalse(myWollokObject.hasVarProperty("nonExistent"))	
	}
	
	def assertProperties(WollokObject myWollokObject) {
		assertFalse(myWollokObject.hasProperty("privateVar"))
		assertTrue(myWollokObject.hasProperty("aVarProperty"))
		assertTrue(myWollokObject.hasProperty("aConstProperty"))
		assertFalse(myWollokObject.hasProperty("aGetter"))
		assertFalse(myWollokObject.hasProperty("aSetter"))
		assertFalse(myWollokObject.hasProperty("aMetthod"))
		assertFalse(myWollokObject.hasProperty("nonExistent"))
	}
	

	
	
}