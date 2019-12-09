package org.uqbar.project.wollok.tests.interpreter

import org.junit.jupiter.api.Test

/**
 * @author jfernandes
 */
class TypeSystemTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testTypeRefinementWithObjectLiterals() { 
		val program = '''
			program p {
				var a = object {         // type = { m1 ; m3 }
					method m1() { }
					method m3() { }
				}
				
				a = object {          // type = { m1 ; m2 }
					method m1() { }
					method m2() { }
				}
				
				// a type = { m1 } (common type)
				
				a.m1()  //FINE !
			}'''
		
		program.interpretPropagatingErrors;
		
		(program.substring(0, program.length - 1) + '''
				a.m2()
				try {
					a.m3()
					assert.fail("should have failed!")
				}
				catch e : MessageNotUnderstoodException {
					// OK !
				}
			}''')
			.interpretPropagatingErrors
	}
	
}