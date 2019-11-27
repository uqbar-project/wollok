package org.uqbar.project.wollok.tests.sdk

import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.After

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
	def void cellSize_works_correctly() {
		'''
		game.cellSize(10)
		'''.gameTest
		assertEquals(10, gameboard.cellsize)
	}
	
	@Test
	def void cellSize_throws_exception_limit(){
		'''
		assert.throwsExceptionWithMessage("Cell size can't be 0 or lower", {=>game.cellSize(0)})
		'''.gameTest
	}
	
	@Test
	def void cellSize_throws_exception(){
		'''
		assert.throwsExceptionWithMessage("Cell size can't be 0 or lower", {=>game.cellSize(-10)})
		'''.gameTest
	}

	def void volumeCantBeHigherThan1() {
		'''
		assert.throwsExceptionWithMessage("Volume value must be between 0 and 1.", { => sound.volume(2.5) })
		'''.soundTest
	}
	
	@Test
	def void volumeCantBeLowerThan0() {
		'''
		assert.throwsExceptionWithMessage("Volume value must be between 0 and 1.", { => sound.volume(-3) })
		'''.soundTest
	}
	
	@Test
	def void soundCantBePlayedIfGameHasntBeenStarted() {
		'''
		assert.throwsExceptionWithMessage("You cannot play sounds until the game has started. Try using it inside an onTick / onPressDo block.", { => sound.play() })
		'''.soundTest
	}
	
	@Test
	def void soundCantBePausedIfItHasntBePlayed() {
		'''
		assert.throwsExceptionWithMessage("You cannot pause or resume a sound that hasn't been played.", { => sound.pause() })
		'''.soundTest
	}	
	
	@Test
	def void soundCantBeStoppedIfItHasntBeenPlayed() {
		'''
		assert.throwsExceptionWithMessage("You cannot stop a sound that hasn't been played.", { => sound.stop() })
		'''.soundTest
	}	
	
	def soundTest(CharSequence test) {
		'''
		import wollok.game.*		
		
		program a {
			const sound = game.sound("testSound.mp3")
			«test»
		}
		'''.interpretPropagatingErrors
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
