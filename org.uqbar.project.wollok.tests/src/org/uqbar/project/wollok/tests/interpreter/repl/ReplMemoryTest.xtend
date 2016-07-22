package org.uqbar.project.wollok.tests.interpreter.repl

import org.eclipse.xtext.junit4.InjectWith
import org.junit.Test
import org.uqbar.project.wollok.tests.injectors.WollokReplInjector
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Tests that the REPL implementation of the interpreter remember the state.
 * @author tesonep
 */
 @InjectWith(WollokReplInjector)
class ReplMemoryTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testMemory() {
		''' 
		program p1 {
			var xxx = 17
		}
		'''.interpretPropagatingErrors
		'''
		program p {
			assert.equals(17, xxx)
		}
		'''.interpretPropagatingErrors
	}
	
}
