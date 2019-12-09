package org.uqbar.project.wollok.tests.quickfix

import org.junit.jupiter.api.Test
import org.uqbar.project.wollok.ui.Messages

class ReturnInParameterQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def removeReturnInParameter(){
		val initial = #['''
		object foo {
			 method bar(){
			 	return 3.min(return 4)
			 }
		}
		''']

		val result = #['''
		object foo {
			 method bar(){
			 	return 3.min(4)
			 }
		}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_return_keyword_name)
	}

}