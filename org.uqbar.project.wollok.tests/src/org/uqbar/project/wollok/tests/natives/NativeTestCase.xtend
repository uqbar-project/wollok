package org.uqbar.project.wollok.tests.natives

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * If you want to run this test, you have to copy `wollok` folder with MyNative Java
 * definitions into your `src` folder (or any other source folder that belongs to the
 * classpath)
 * 
 * @author jfernandes
 */
class NativeTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testClassWithNativeMethod() {
		#["natives"->'''
			class MyNative {
				method aNativeMethod() native
				
				method uppercased() {
					return self.aNativeMethod().toUpperCase()
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
					return self.aNativeMethod().toUpperCase()
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
	
	@Test
	def void nativeMethodInAFakeNativeClass() {
		#["natives"->'''
			class FakeNativeClass {
				method aNativeMethod() native
			}
			
			test "native method in a fake native class" {
				assert.throwsExceptionWithMessage("You declared a native method but there is no native definition for natives.FakeNativeClass (maybe it is a pure Wollok definition)", 
				{ new FakeNativeClass() })
			}
		''']
		.interpretPropagatingErrors
	}
	
}