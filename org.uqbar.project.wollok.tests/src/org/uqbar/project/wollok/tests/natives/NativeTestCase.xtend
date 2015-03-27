package org.uqbar.project.wollok.tests.natives

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

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
	
	
}