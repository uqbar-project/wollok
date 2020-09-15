package org.uqbar.project.wollok.tests.sdk

import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.After
import org.uqbar.project.wollok.game.listeners.KeyboardListener

class GameTest extends AbstractWollokInterpreterTestCase {
	
	val gameboard = Gameboard.getInstance
	
	@Before
	def void init() {
		gameboard.clear
	}
	
	@After
	def void finish() {
		Gameboard.resetInstance
	}

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

	@Test
	def void configOnPressKey() {
		'''
		keyboard.left().onPressDo({ })
		'''.gameTest
		val keyListener = gameboard.listeners.head as KeyboardListener 
		assertEquals("ArrowLeft", keyListener.keyCode)
	}
	
	// We should publish a cellSize property in game wko to migrate this test to wollok-language
	@Test
	def void cellSize_works_correctly() {
		'''
		game.cellSize(10)
		'''.gameTest
		assertEquals(10, gameboard.cellsize)
	}
	
	def gameTest(CharSequence test) {
		'''
		import wollok.game.*
		
		object pepita {
			var property position = game.origin()
		}
		
		program a {
			«test»
		}
		'''.interpretPropagatingErrors
	}

}
