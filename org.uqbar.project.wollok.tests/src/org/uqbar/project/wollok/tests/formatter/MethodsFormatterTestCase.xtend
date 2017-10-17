package org.uqbar.project.wollok.tests.formatter

import org.junit.Ignore
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

	// TODO: Metodos que devuelvan con =
	// TODO 2: Metodos que redefinen otros de la superclase (override)
	// TODO 3: metodos nativos
	// TODO 4: Uso de super	
}