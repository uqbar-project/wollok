package org.uqbar.project.wollok.tests.parser

import org.junit.jupiter.api.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/** 
 * Test representative error messages for constructors
 * @author dodain
 */
class OrderConstructionParserTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void ProgramVsClases() {
		'''
		program abc {
		    new Pepita().comer()
		}
		
		class Pepita {
			method comer()
		}
		'''.expectsSyntaxError("Bad structure: class definition must be before program.", false)
	}

	@Test
	def void ProgramVsWko() {
		'''
		program abc {
		    pepita.comer()
		}
		
		object pepita {
			method comer()
		}
		'''.expectsSyntaxError("Bad structure: object definition must be before program.", false)
	}

	@Test
	def void TestVsWko() {
		'''
		test "pepita is eating!" {
		    pepita.comer()
		}
		
		object pepita {
			method comer()
		}
		'''.expectsSyntaxError("Bad structure: object definition must be before test.", false)
	}

	@Test
	def void TestVsClass() {
		'''
		test "pepita is eating!" {
		    new Ave().comer()
		}
		
		class Ave {
			method comer()
		}
		'''.expectsSyntaxError("Bad structure: class definition must be before test.", false)
	}

}