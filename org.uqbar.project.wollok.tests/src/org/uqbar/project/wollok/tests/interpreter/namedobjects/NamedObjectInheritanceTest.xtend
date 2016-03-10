package org.uqbar.project.wollok.tests.interpreter.namedobjects

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * Tests named objecst inheriting from a class
 * 
 * @author jfernandes
 */
class NamedObjectInheritanceTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void noExplicitParentMeansObjectSuperclass() {
		'''
			object myObject {
				method something() = "abc"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals(myObject, (myObject->"42").getX())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromCustomClass() {
		'''
			class MyClass {
				method myMethod() = "1234"
			}
			object myObject inherits MyClass {
				method something() = "abc"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals("1234", myObject.myMethod())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromCustomClassAndOverridesMethod() {
		'''
			class MyClass {
				method myMethod() = "1234"
			}
			object myObject inherits MyClass {
				method something() = "abc"
				override method myMethod() = "5678"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals("5678", myObject.myMethod())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromCustomClassAndOverridesMethodCallingSuper() {
		'''
			class MyClass {
				method myMethod() = "1234"
			}
			object myObject inherits MyClass {
				method something() = "abc"
				override method myMethod() = super() + "5678"
			}
			
			program p {
				assert.equals("abc", myObject.something())
				assert.equals("12345678", myObject.myMethod())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromClassThatHasConstructor() {
		'''
			class Dog {
				const name
				constructor(param) {
					name = param
				}	
				method name() = name
			}
			object lassie inherits Dog("lassie") {
			}
			
			program p {
				assert.equals("lassie", lassie.name())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromClassThatHasConstructorPassingAnotherWKOAsArgument() {
		'''
			class Dog {
				const owner
				constructor(param) {
					owner = param
				}	
				method owner() = owner
			}
			object lassie inherits Dog(jorge) {
			}
			
			object jorge {
				method name() = "Jorge"
			}
			
			program p {
				assert.equals(jorge, lassie.owner())
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void objectInheritFromClassThatHasConstructorPassingAnotherWKOMessageReturnValue() {
		'''
			class Dog {
				const owner
				constructor(param) {
					owner = param
				}	
				method owner() = owner
			}
			object lassie inherits Dog(jorge.name()) {
			}
			
			object jorge {
				method name() = "Jorge"
			}
			
			program p {
				assert.equals("Jorge", lassie.owner())
			}
		'''.interpretPropagatingErrors
	}
	
}