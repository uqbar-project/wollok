package org.uqbar.project.wollok.tests.sdk

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

class GameTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void canInstanceNewPosition() {
		'''
		assert.equals(new Position(1,2), game.at(1,2))
		'''.test
	}
}