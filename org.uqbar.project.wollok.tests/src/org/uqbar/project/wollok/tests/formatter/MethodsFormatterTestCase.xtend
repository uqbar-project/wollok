package org.uqbar.project.wollok.tests.formatter

import org.junit.Test

class MethodsFormatterTestCase extends AbstractWollokFormatterTestCase {

	@Test
	def void testBasicFormattingInMethod() {
		assertFormatting(
		'''
		object        foo     {
		method bar(     param  ,  param2      ) {
		console.println("")
		console.println("")
		}
		}
		''',
		'''
		object foo {
			method bar(param, param2) {
				console.println("")
				console.println("")
			}
		}
		'''
		)
	}

	@Test
	def void testBasicFormattingSeveralMethods() {
		assertFormatting(
		'''
		             object        foo     {
		method bar(     param  ,  param2      ) {
		console.println("")
		console.println("")
		}method bar2() { return 3 }
		

method bar3() { assert.that(true)		var a = 1 + 1 console.println(a)}		
		}
		''',
		'''
		object foo {
			method bar(param, param2) {
				console.println("")
				console.println("")
			}
			method bar2() {
				return 3
			}
			method bar3() {
				assert.that(true)
				var a = 1 + 1
				console.println(a)
			}
		}
		'''
		)
	}
	
}