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
			val obj = new MyNative()
			val response = obj.aNativeMethod()
			this.assertEquals('Native hello message!', response)
			
			this.assertEquals('NATIVE HELLO MESSAGE!', obj.uppercased())
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
			
			class ANativeSubclass extends MyNative {
				method subclassNativeMethod() native
			}

		program nativeSample {
			val obj = new ANativeSubclass()
			
			this.assertEquals('Native hello message!', obj.aNativeMethod())
			this.assertEquals('A Subclass Native Method', obj.subclassNativeMethod())
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
			this.assertEquals('Native object hello message!', aNative.aNativeMethod())
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
}