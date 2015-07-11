package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Tests that the numbers works as expected when mixing integer and doubles
 * 
 * @author tesonep
 */
class MixedNumberTypesOperations extends AbstractWollokInterpreterTestCase {

	@Test
	def void testEquals() {
		'''
			program a {
				assert.equals(2 * 2.0, 2.0 * 2)
				assert.equals(2 * 2.0, 2.0 * 2)
				assert.equals(2 * 2, 2.0 * 2)
				assert.equals(2 * 2, 2 * 2.0)
				
				assert.equals(1 + 2.0, 1.0 + 2)
				assert.equals(1 + 2.0, 1.0 + 2)
				assert.equals(1 + 2, 1.0 + 2)
				assert.equals(1 + 2, 1 + 2.0)
				
				assert.equals(1 - 2.0, 1.0 - 2)
				assert.equals(1 - 2.0, 1.0 - 2)
				assert.equals(1 - 2, 1.0 - 2)
				assert.equals(1 - 2, 1 - 2.0)
				
				assert.equals(1 / 2.0, 1.0 / 2)
				assert.equals(1 / 2.0, 1.0 / 2)
			}
		'''.interpretPropagatingErrors
	}
}
