package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions

/**
 * 
 * New tests using describe abstraction that groups tests 
 * 
 * @author dodain
 */
class TestDescribeTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testFixtureErrorBreaksTestsInDescribe() throws Exception {
		Assertions.assertThrows(WollokProgramExceptionWrapper, ['''
		describe "conjunto de tests re locos" {
		
			var uno
			
			fixture {
				uno = 1 / 0	
			}
			
			method uno() = uno
			method dos() = self.uno() + 1
			
			test "uno es uno" {
				assert.equals(1, uno)
			}
		
			test "dos es dos" {
				const dos = self.dos()
				self.uno()
				assert.equals(2, dos)
			}
			
		}
		'''.interpretPropagatingErrors
	])
	}

}
