package org.uqbar.project.wollok.tests.natives

import org.junit.Ignore
import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * @author jfernandes
 */
@Ignore // started to break running in osgi (maven). Probably due to class.forname() in native impl
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