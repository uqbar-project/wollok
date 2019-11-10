package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class ChangeVarToConstQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def testChangeToConst() {
		val initial = #['''
			object anObject {
				var shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']

		val result = #['''
			object anObject {
				const shouldBeConst = 10
				method getShouldBeConst() {
					return shouldBeConst
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_changeToConst_name)
	}
}
