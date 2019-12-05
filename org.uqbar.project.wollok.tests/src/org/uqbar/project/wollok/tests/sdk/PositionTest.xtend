package org.uqbar.project.wollok.tests.sdk

import org.junit.Before
import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
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

	// Este test solo funciona internamente, no es posible llevarlo a wollok-language
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
