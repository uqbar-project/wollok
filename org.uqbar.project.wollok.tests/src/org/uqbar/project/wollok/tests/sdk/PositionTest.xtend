package org.uqbar.project.wollok.tests.sdk

import org.junit.Before
import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.lib.WollokConventionExtensions
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

class PositionTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String convention

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		WollokConventionExtensions.POSITION_CONVENTIONS.asParameters
	}

	var position = "new Position(x = 0, y = 0)"
	var gameboard = Gameboard.getInstance
	
	@Before
	def void init() {
		gameboard.clear
	}

	@Test
	def void canInstancePosition() {
		'''
		var p = «position»
		'''.test
	}
	
	@Test
	def void equalityByCoordinates() {
		'''
		assert.equals(new Position(x = 0, y = 0), «position»)
		'''.test
	}
	
	@Test
	def void testToString() {
		'''
		assert.equals("(0,0)", «position».toString())
		'''.test
	}
	
	@Test
	def void distanceUsingNull() {
		'''
		assert.throwsExceptionWithMessage("Operation distance doesn't support null parameters", { => new Position(x = 1, y = 2).distance(null) })
		'''.test
	}
	
	@Test
	def void testDistance() {
		'''
		assert.equals(5, «position».distance(new Position(x = 3, y = 4)))
		'''.test
	}

	@Test
	def void shouldDrawVisualObjectsInBoard() {
		assertEquals(0, components.size)
		
		'''
		«visualObjectWithoutPosition»
		program p {
			«position».drawElement(visual)
		}'''.interpretPropagatingErrors
		
		assertEquals(1, components.size)
	}

	@Test
	def void positionCanBeAccessedByGetterMethod() {
		'''
		import wollok.game.*
		
		object aVisual {
			method «convention»() = «position»
			«imageMethod»
		}
		
		object otherVisual {
			method «convention»() = «position»
			«imageMethod»
		}
		
		program p {
			game.addVisual(aVisual)
			game.addVisual(otherVisual)
		}'''.interpretPropagatingErrors
		
		validatePosition
	}

	@Test
	def void positionCanBeAccessedByProperty() {
		'''
		import wollok.game.*
		
		object visual {
			var property «convention» = «position»
			«imageMethod»
		}
		
		program p {
			game.addVisual(visual)
		}'''.interpretPropagatingErrors
		
		validatePosition
	}

	@Test
	def void positionCannotBeAccessedByAttribute() {
		'''
		import wollok.game.*
		
		object visual {
			var «convention» = «position»
			«imageMethod»
		}
		
		program p {
			assert.throwsExceptionWithMessage("visual<position=a Position<x=0, y=0>> does not understand position()", { game.addVisual(visual) })
		}'''.interpretPropagatingErrors
	}

	@Test
	def void visualsWithoutPositionCantBeRendered() {
		'''
		«visualObjectWithoutPosition»
		program p {
			assert.throwsException{ game.addVisual(visual) }
		}'''.interpretPropagatingErrors
	}

	@Test
	def void positionsCanDrawVisualsWithoutPosition() {
		'''
		«visualObjectWithoutPosition»
		program p {
			var position = «position»
			position.drawElement(visual)
			var expected = position.allElements().head()
			assert.equals(expected, visual)
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void whenClearShouldRemoveAllVisualsInIt() {
		'''
		import wollok.game.*
		
		class Visual {
			«imageMethod»
		}
		
		program p {
			2.times{ i => «position».drawElement(new Visual()) }
			new Position(x = 1, y = 1).drawElement(new Visual())
		}'''.interpretPropagatingErrors
		
		assertEquals(3, gameboard.components.size)
		'''
		import wollok.game.*
		
		program p {
			«position».clear()
		}'''.interpretPropagatingErrors
		
		assertEquals(1, gameboard.components.size)
	}
	
	@Test
	def void sayShouldAddBallonMessageToVisualObject() {
		var message = "A message"
		'''
		«visualObjectWithoutPosition»
		program p {
			var position = «position»
			position.drawCharacter(visual)
			position.say(visual, "«message»")
		}'''.interpretPropagatingErrors
		
		assertEquals(message, gameboard.character.balloonMessages.head.text)
	}
	
	def validatePosition() {
		components.forEach[
			assertEquals(new WGPosition(0,0), it.position)
		]
	}
	
	def components() {
		gameboard.components
	}
	
	def visualObjectWithoutPosition() {
		'''
		import wollok.game.*
		
		object visual {
			«imageMethod»
		}
		'''
	}
	
	def imageMethod() {
		'''
		method getImage() = "image.png"
		'''
	}
}
