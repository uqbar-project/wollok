package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class RuntimeTest extends AbstractWollokInterpreterTestCase {
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
