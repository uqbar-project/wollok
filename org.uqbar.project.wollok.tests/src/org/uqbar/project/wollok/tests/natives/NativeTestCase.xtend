package org.uqbar.project.wollok.tests.natives

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * @author jfernandes
 */
class NativeTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testClassWithNativeMethod() {
		#['''package org.uqbar.project.wollok.tests.natives {
		
			class MyNative {
				method aNativeMethod() native
				
				method uppercased() {
					return this.aNativeMethod().toUpperCase()
				} 
			}
		
		}''',
		'''
		import org.uqbar.project.wollok.tests.natives.MyNative

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
		#['''package org.uqbar.project.wollok.tests.natives {
		
			class MyNative {
				method aNativeMethod() native
				
				method uppercased() {
					return this.aNativeMethod().toUpperCase()
				} 
			}
			
			class ANativeSubclass extends MyNative {
				method subclassNativeMethod() native
			}
		
		}'''
		,'''
		import org.uqbar.project.wollok.tests.natives.MyNative
		import org.uqbar.project.wollok.tests.natives.ANativeSubclass

		program nativeSample {
			val obj = new ANativeSubclass()
			
			this.assertEquals('Native hello message!', obj.aNativeMethod())
			this.assertEquals('A Subclass Native Method', obj.subclassNativeMethod())
		}
		'''
		].interpretPropagatingErrors
	}
	
	@Test
	def void testObjectWithNativeMethod() {
		#['''package org.uqbar.project.wollok.tests.natives {
		
			object aNative {
				method aNativeMethod() native
			}
		
		}'''
		,'''
		import org.uqbar.project.wollok.tests.natives.*

		program nativeSample {
			this.assertEquals('Native object hello message!', aNative.aNativeMethod())
		}
		'''
		].interpretPropagatingErrors
	}
	
}