package org.uqbar.project.wollok.tests.sdk

import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import org.junit.Before

class GameTest extends AbstractWollokInterpreterTestCase {
	
	var gameboard = Gameboard.getInstance
	
	@Before
	def void init() {
		gameboard.clear
	}
	
	@Test
	def void canInstanceNewPosition() {
		'''
		assert.equals(«position(1,2)», game.at(1,2))
		'''.test
	}
	
	@Test
	def void originShouldReturnOriginCoordinatePosition() {
		'''
		assert.equals(«position(0,0)», game.origin())
		'''.test
	}
	
	@Test
	def void centerShouldReturnCenteredCoordinatePosition() {
		'''
		game.width(2)
		game.height(5)
		assert.equals(«position(1,2)», game.center())
		'''.test
	}
	
	@Test
	def void shouldReturnVisualColliders() {
		'''
		import wollok.game.*
		
		object myVisual { }
		class Visual { }
		
		program a {
			«position(0,0)».drawElement(myVisual)
			2.times{ i => «position(0,0)».drawElement(new Visual()) }
			«position(0,1)».drawElement(new Visual())
			
			assert.equals(2, game.colliders(myVisual).size())
		}
		'''.interpretPropagatingErrors
	}
	
	private def position(int x, int y) {
		'''new Position(x = «x», y = «y»)'''
	}
	
	@Test
	def void addVisualUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation addVisual doesn't support null parameters", { => game.addVisual(null) })
		'''.test
	}

	@Test
	def void addVisualInUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation addVisualIn doesn't support null parameters", { => game.addVisualIn(null, null) })
		'''.test
	}

	@Test
	def void collidersUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation colliders doesn't support null parameters", { => game.colliders(null) })
		'''.test
	}

	@Test
	def void onTickUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation onTick doesn't support null parameters", { => game.onTick(null, null, null) })
		'''.test
	}

	@Test
	def void whenKeyPressedDoUsingNullMustFail() {
		'''
		assert.throwsExceptionWithMessage("Operation whenKeyPressedDo doesn't support null parameters", { => game.whenKeyPressedDo(null, null) })
		'''.test
	}

	@Test
	def void whenAddingAnObjectAndCheckingIfItIsInTheBoardItReturnsTrue() {
		'''
		import wollok.game.*

		object myVisual { }

		program a {
			game.addVisualIn(myVisual, game.at(0, 0))
			assert.that(game.hasVisual(myVisual))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void whenAddingAnObjectAndCheckingIfOtherIsInTheBoardItReturnsFalse() {
		'''
		import wollok.game.*

		object myVisual { }
		object myVisual2 { }

		program a {
			game.addVisualIn(myVisual, game.at(0, 0))
			assert.notThat(game.hasVisual(myVisual2))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void whenNoObjectIsAddedAndGetAllVisualsItReturnsNoElement() {
		'''
		import wollok.game.*

		program a {
			assert.equals(0, game.getAllVisuals().size())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void whenAddingAnObjectAndGettingAllVisualsItReturnsOneElement() {
		'''
		import wollok.game.*

		object myVisual { }

		program a {
			game.addVisualIn(myVisual, game.at(0, 0))
			assert.equals(1, game.getAllVisuals().size())
			assert.equals(myVisual, game.getAllVisuals().get(0))
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void whenAddingSomeObjectAndGettingAllVisualsItReturnsAllTheAddedElements() {
		'''
		import wollok.game.*

		object myVisual { }
		object myVisual2 { }
		object myVisual3 { }

		program a {
			game.addVisualIn(myVisual, game.at(0, 0))
			game.addVisualIn(myVisual2, game.at(0, 0))
			game.addVisualIn(myVisual3, game.at(0, 0))
			assert.equals(3, game.getAllVisuals().size())
			assert.equals([myVisual, myVisual2, myVisual3].asSet(), game.getAllVisuals().asSet())
		}
		'''.interpretPropagatingErrors
	}
}
