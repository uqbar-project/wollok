package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Tests that the numbers works as expected when mixing integer and doubles
 * 
 * @author tesonep
 */
class MixedNumberTypesOperationsTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testEquals() {
		'''
			program a {
				assert.equals(2 * 2.0, 2.0 * 2)
				assert.equals(2 * 2.0, 2.0 * 2)
				
				assert.equals(1 + 2.0, 1.0 + 2)
				assert.equals(1 + 2.0, 1.0 + 2)
				
				assert.equals(1 - 2.0, 1.0 - 2)
				assert.equals(1 - 2.0, 1.0 - 2)
				
				assert.equals(1 / 2.0, 1.0 / 2)
				assert.equals(1 / 2.0, 1.0 / 2)
			}
		'''.interpretPropagatingErrors
	}
	@Test
	def void testFloatOperation(){
		'''
			program a {
				assert.equals(100 * 1.1, 110.0)
				assert.equals(100 * 1.1, 110.0)
				
				assert.equals(1.4 * 1.4, 1.96)
				assert.equals(1.4 * 1.4, 1.96)
			}
		'''.interpretPropagatingErrors		
	}	
}
