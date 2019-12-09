package org.uqbar.project.wollok.tests.quickfix

import org.junit.jupiter.api.Test
import org.uqbar.project.wollok.ui.Messages

/**
 * author dodain
 */
class IfQuickFixTest extends AbstractWollokQuickFixTestCase {
	
	@Test
	def testReplaceAssignmentWithComparisonInsideAnIfExpression(){
		val initial = #['''
		object pepe {
		
			var a = 2
			const b = 2
		
			method foo() {
				if (a    =  b)
					throw new Exception(message = "asd")
			}
		}
		''']

		val result = #['''
		object pepe {
		
			var a = 2
			const b = 2
		
			method foo() {
				if (a == b)
					throw new Exception(message = "asd")
			}
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_assignment_with_comparison_name)
	}

}