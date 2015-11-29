package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

class CollectionsMinMaxTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testMin() {
		'''
				object x1 {
					method value(){ return 1 }
				}
				object x2 {
					method value(){ return 2 }
				}
				object x3 {
					method value(){ return 3 }
				}				

				program a {
					assert.equals(x1, #[x1, x2, x3].min[ o | o.value()])
				}
			'''
		.interpretPropagatingErrors
	}

	@Test
	def void testMax() {
			'''
				object x1 {
					method value(){ return 1 }
				}
				object x2 {
					method value(){ return 2 }
				}
				object x3 {
					method value(){ return 3 }
				}

				program a {
					assert.equals(x3, #[x1, x2, x3].max[ o | o.value()])
				}
			'''
		.interpretPropagatingErrors
	}
}
