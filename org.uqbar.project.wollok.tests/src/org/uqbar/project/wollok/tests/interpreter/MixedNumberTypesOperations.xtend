package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

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
			this.assert(2 * 2.0 == 2.0 * 2)
			this.assert(2 * 2.0 == 2.0 * 2)
			this.assert(2 * 2 == 2.0 * 2)
			this.assert(2 * 2 == 2 * 2.0)
			
			this.assert(1 + 2.0 == 1.0 + 2)
			this.assert(1 + 2.0 == 1.0 + 2)
			this.assert(1 + 2 == 1.0 + 2)
			this.assert(1 + 2 == 1 + 2.0)

			this.assert(1 - 2.0 == 1.0 - 2)
			this.assert(1 - 2.0 == 1.0 - 2)
			this.assert(1 - 2 == 1.0 - 2)
			this.assert(1 - 2 == 1 - 2.0)
						
			this.assert(1 / 2.0 == 1.0 / 2)
			this.assert(1 / 2.0 == 1.0 / 2)
			}
		'''.interpretPropagatingErrors
	}

}
