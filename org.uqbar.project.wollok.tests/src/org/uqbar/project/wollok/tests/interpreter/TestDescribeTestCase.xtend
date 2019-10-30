package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * 
 * New tests using describe abstraction that groups tests 
 * 
 * @author dodain
 */
class TestDescribeTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test(expected=AssertionError)
	def void testShouldNotUseSameVariableDefinedInDescribe() {
		'''
		describe "pruebas generales" {
			const a = 8
			const b = 5
			
			test "Max between 5 and 8" {
				const a = 3
				const result = 5.max(8)
				assert.equals(8, result)
			}
			test "Min between 5 and 8" {
				const result = 5.min(8)
				assert.equals(5, result)
			}
		}
		'''.interpretPropagatingErrors
	}
	
	@Test(expected=WollokProgramExceptionWrapper)
	def void testFixtureErrorBreaksTestsInDescribe() {
		'''
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
				var dos = self.dos()
				self.uno()
				assert.equals(2, dos)
			}
			
		}
		'''.interpretPropagatingErrors
	}

}
