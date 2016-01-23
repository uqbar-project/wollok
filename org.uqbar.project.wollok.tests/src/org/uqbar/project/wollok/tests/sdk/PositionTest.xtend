package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest
import org.uqbar.project.wollok.lib.WollokConventionExtensions
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.junit.Before

class PositionTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String convention

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		WollokConventionExtensions.POSITION_CONVENTIONS.asParameters
	}

	var gameboard = Gameboard.getInstance
	
	@Before
	def void init() {
		gameboard.clear()
	}

	@Test
	def void canInstancePosition() {
		'''
		program p {
			var p = new Position(0,0)
		}'''.interpretPropagatingErrors
	}

	@Test
	def void shouldAddVisualObjectsToBoard() {
		'''
		program p {
			var visual = object {
				method image() = "image.png"
			}

			new Position(0,0).drawElement(visual)
		}'''.interpretPropagatingErrors
		
		assertEquals(1, gameboard.components.size)
	}

	@Test
	def void shouldremoveVisualObjectsFromBoard() {
		'''
		program p {
			var visual = object {
				method image() = "image.png"
			}

			var position = new Position(0,0)
			position.drawElement(visual)
			position.removeElement(visual)
		}'''.interpretPropagatingErrors
		
		assertEquals(0, gameboard.components.size)
	}
	
	@Test
	def void positionCanBeAccessedByGetterMethod() {
		'''
		program p {
			var aVisual = object {
				method get«convention.toFirstUpper»() = new Position(0,0)
				method getImage() = "image.png"
			}
			
			var otherVisual = object {
				method «convention»() = new Position(0,0)
				method getImage() = "image.png"
			}
		
			wgame.addVisual(aVisual)
			wgame.addVisual(otherVisual)
		}'''.interpretPropagatingErrors
	}

	@Test
	def void positionCanBeAccessedByProperty() {
		'''
		program p {
			var visual = object {
				var «convention» = new Position(0,0)
				
				method getImagen() = "image.png"
			}
		
			wgame.addVisual(visual)
		}'''.interpretPropagatingErrors
	}

	@Test
	def void visualsWithoutPositionCantBeRendered() {
		try {
			'''
			object visual {
				method getImage() = "image.png"
			}
			
			program p {
				wgame.addVisual(visual)
			}'''.interpretPropagatingErrors
		} catch (AssertionError exception) {
			assertTrue(exception.message.contains("Visual object doesn't have any position"))
		}
	}

	@Test
	def void positionsCanDrawVisualsWithoutPosition() {
		'''
		object visual {
			method getImage() = "image.png"
		}
		
		program p {
			var position = new Position(0,0)
			position.drawElement(visual)
			var expected = position.allElements().head()
			assert.equals(expected, visual)
		}'''.interpretPropagatingErrors
	}
}
