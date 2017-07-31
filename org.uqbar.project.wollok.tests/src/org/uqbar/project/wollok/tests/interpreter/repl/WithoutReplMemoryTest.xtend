package org.uqbar.project.wollok.tests.interpreter.repl

import org.eclipse.xtext.testing.InjectWith
import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

/**
 * Tests that the default implementation of the interpreter
 * does not remember state between runs.
 * 
 * @author tesonep
 */
 @InjectWith(WollokTestInjectorProvider)
class WithoutReplMemoryTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testMemory() {
		''' 
		program p1 {
			var xxx = 17
		}
		'''.interpretPropagatingErrors
		'''
		program p {
			var xxx
			assert.equals(null, xxx)
		}
		'''.interpretPropagatingErrors
	}
}
