package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Basic Tests for methods writting
 * 
 * @author tesonep
 */
class MethodsTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void literals() {
		#["objects" -> '''
			class A {
				method method1(asd) {
					return asd + 1
				}
				method method2(asd) = asd + 1
				method method3(asd) = 4
				method method4(asd) = return 4
			}
		''',
		"pgm" -> '''
			import objects.A
			
			program xxx {
				const x = new A()
				
				assert.equals(x.method1(2), 3)
				assert.equals(x.method2(2), 3) 	
				assert.equals(x.method3(2), 4) 	
				assert.equals(x.method4(2), 4) 					
			}
		'''
		].interpretPropagatingErrors
	}

}
