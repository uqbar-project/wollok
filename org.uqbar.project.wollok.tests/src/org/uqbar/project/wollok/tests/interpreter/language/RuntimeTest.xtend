package org.uqbar.project.wollok.tests.interpreter.language

import org.junit.Test

class RuntimeTest extends org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase {
	@Test
	def void testInteractive() {
		'''
			import wollok.vm.runtime
			
			program p {
				assert.notThat(runtime.isInteractive())
			}
		'''.interpretPropagatingErrors
	}
}
