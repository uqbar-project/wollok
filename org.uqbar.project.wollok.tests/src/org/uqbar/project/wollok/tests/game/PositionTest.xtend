package org.uqbar.project.wollok.tests.game

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import org.uqbar.project.wollok.game.WPosition
import wollok.lib.AssertionException

class PositionTest extends AbstractWollokInterpreterTestCase {

	val conventions = WPosition.CONVENTIONS

	@Test
	def void positionAccessedByGetterMethod() {
		conventions.forEach [
			'''
			program p {
				var aVisual = object {
					method get«it.toFirstUpper»() = new Position(0,0)
					method getImagen() = "anImage.png"
				}
				
				var otherVisual = object {
					method «it»() = new Position(0,0)
					method getImagen() = "anImage.png"
				}
			
				wgame.addVisual(aVisual)
				wgame.addVisual(otherVisual)
			}'''.interpretPropagatingErrors
		]
	}
	
	@Test
	def void positionAccessedByProperty() {
		conventions.forEach [
			'''
			program p {
				var visual = object {
					var «it» = new Position(0,0)
					
					method getImagen() = "anImage.png"
				}
			
				wgame.addVisual(visual)
			}'''.interpretPropagatingErrors
		]
	}
	
	@Test
	def void visualsWithoutPositionCantBeRendered() {
		try {
			'''
			object visual {
				method getImagen() = "anImage.png"
			}
			
			program p {
				wgame.addVisual(visual)
			}'''.interpretPropagatingErrors
		} catch (AssertionError exception) {
			assertTrue(exception.message.contains("Visual object doesn't have any position"))
		}
	}
}
