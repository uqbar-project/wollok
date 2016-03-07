package org.uqbar.project.wollok.tests.natives

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * @author jfernandes
 */
class NativeTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testClassWithNativeMethod() {
		#["natives"->'''
			class MyNative {
				method aNativeMethod() native
				
				method uppercased() {
					return this.aNativeMethod().toUpperCase()
				} 
			}

		program nativeSample {
			const obj = new MyNative()
			const response = obj.aNativeMethod()
			assert.equals('Native hello message!', response)
			
			assert.equals('NATIVE HELLO MESSAGE!', obj.uppercased())
		}
		'''].interpretPropagatingErrors
	}
	
	@Test
	def void nativeMethodsInManyClassesInTheHierarchy() {
		#["natives"->'''
			class MyNative {
				method aNativeMethod() native
				
				method uppercased() {
					return this.aNativeMethod().toUpperCase()
				} 
			}
			
			class ANativeSubclass inherits MyNative {
				method subclassNativeMethod() native
			}

		program nativeSample {
			const obj = new ANativeSubclass()
			
			assert.equals('Native hello message!', obj.aNativeMethod())
			assert.equals('A Subclass Native Method', obj.subclassNativeMethod())
		}
		''']
		.interpretPropagatingErrors
	}
	
	@Test
	def void testObjectWithNativeMethod() {
		#["natives"->'''
			object aNative {
				method aNativeMethod() native
			}

		program nativeSample {
			assert.equals('Native object hello message!', aNative.aNativeMethod())
		}
		''']
		.interpretPropagatingErrors
	}
	
	
	@Test
	def void testConsole() {
		'''
		program nativeSample {
			console.println("Hola")
		}
		'''
		.interpretPropagatingErrors
	}
	
	@Test
	def void nativeClassWithAccessToWollokObject() {
		#["natives"->'''
			class MyNativeWithAccessToObject {
				var initialValue = 42
				method lifeMeaning() native
				method newDelta(d) native
				
				method initialValue() {
					return initialValue
				} 
			}

		program nativeSample {
			const obj = new MyNativeWithAccessToObject()
			
			assert.equals(42, obj.initialValue())
			assert.equals(100 + 42, obj.lifeMeaning())
			
			obj.newDelta(200)
			
			assert.equals(200 + 42, obj.lifeMeaning())
		}
		''']
		.interpretPropagatingErrors
	}
	
	@Test
	def void methodWithNativeMessageAnnotation() {
		#["natives"->'''
			class MyNativeWithAccessToObject {
				method final() native
			}

		program nativeSample {
			const obj = new MyNativeWithAccessToObject()
			
			assert.equals(500, obj.final())
		}
		''']
		.interpretPropagatingErrors
	}
}