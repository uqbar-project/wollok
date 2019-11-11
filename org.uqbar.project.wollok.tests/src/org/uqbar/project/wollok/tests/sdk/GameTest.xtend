package org.uqbar.project.wollok.tests.sdk

import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

class GameTest extends AbstractWollokInterpreterTestCase {
	
	val gameboard = Gameboard.getInstance
	
	@Before
	def void init() {
		gameboard.clear
	}
	
	// Este test solo funciona internamente, no es posible llevarlo a wollok-language
	@Test
	def void movingCharacterShouldSetObjectPosition() {
		'''
		game.addVisualCharacter(pepita)
		'''.gameTest
		gameboard.components.head.up
		'''
		assert.equals(1, game.at(0,1).allElements().size())
		'''.test
	}
	
	def gameTest(CharSequence test) {
		'''
		import wollok.game.*
		
		object myVisual { }
		class Visual { }
		
		object pepita {
			var property position = game.origin()
		}
		
		program a {
			«test»
		}
		'''.interpretPropagatingErrors
	}
	
}
