package org.uqbar.project.wollok.tests.interpreter.numbers

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

class CollectionsMinMax extends AbstractWollokInterpreterTestCase {

	@Test
	def void testMin() {
		#[
			"objs" -> '''
				object x1 {
					method value(){ return 1 }
				}
				object x2 {
					method value(){ return 2 }
				}
				object x3 {
					method value(){ return 3 }
				}				
			''',
			"pgm"->'''
				import objs.*
			
				program a {
					assert.equals(x1, #[x1, x2, x3].min[ o | o.value()])
				}
			'''
		].interpretPropagatingErrors
	}

	@Test
	def void testMax() {
		#[
			"objs" -> '''
				object x1 {
					method value(){ return 1 }
				}
				object x2 {
					method value(){ return 2 }
				}
				object x3 {
					method value(){ return 3 }
				}				
			''',
			"pgm" -> '''
				import objs.*
				program a {
					assert.equals(x3, #[x1, x2, x3].max[ o | o.value()])
				}
			'''
		].interpretPropagatingErrors
	}
}
