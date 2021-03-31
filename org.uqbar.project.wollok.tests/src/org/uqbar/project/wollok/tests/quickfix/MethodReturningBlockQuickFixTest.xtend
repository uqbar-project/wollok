package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class MethodReturningBlockQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def removeEqualsInMethodReturningBlock(){
		val initial = #['''
			object myObj {
				method someMethod() = { return 4 }
			}
		''']

		val result = #['''
			object myObj {
				method someMethod() { return 4 }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_equals_before_method_name)		
	}

}