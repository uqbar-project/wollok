package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * Tests for if conditions
 * 
 * @author dodain
 */
class IfTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void ifConditionAsANumber() {
		'''
		object numeroLoco {
			method calculoLoco(n) {
				if (n) {
					return 0
				}
				return n
			}
		}
		
		test "if condition as a number" {
			assert.throwsExceptionWithMessage("Expression in 'if' must evaluate to a boolean. Instead got: 3 (Number)", { => numeroLoco.calculoLoco(3) })
		}
		'''.interpretPropagatingErrors
	}
	
}