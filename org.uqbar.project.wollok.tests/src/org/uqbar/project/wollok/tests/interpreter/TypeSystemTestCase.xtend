package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

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
		
		program.interpretPropagatingErrors
		
		try {
			(program.substring(0, program.length - 1) + '''
				a.m2()
				a.m3()
			}''')
			.interpretPropagatingErrors
			fail()
		}
		catch (WollokProgramExceptionWrapper e) {
		}
	}
	
}