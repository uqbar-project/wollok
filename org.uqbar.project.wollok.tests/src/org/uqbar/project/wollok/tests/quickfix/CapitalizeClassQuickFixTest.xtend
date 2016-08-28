package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class CapitalizeClassQuickFixTest extends AbstractWollokQuickFixTestCase {
	@Test
	def testCapitalizeName(){
		val initial = #['''
			class myClass{
				method someMethod(){
					return null
				}
			}
		''']

		val result = #['''
			class MyClass{
				method someMethod(){
					return null
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickfixProvider_capitalize_name)
	}
}