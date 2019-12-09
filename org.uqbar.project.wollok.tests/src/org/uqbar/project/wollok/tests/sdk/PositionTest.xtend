package org.uqbar.project.wollok.tests.sdk

import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.params.ParameterizedTest
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.lib.WollokConventionExtensions
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest
import org.junit.jupiter.params.provider.MethodSource

class PositionTest extends AbstractWollokParameterizedInterpreterTest {

	static def data() {
		WollokConventionExtensions.POSITION_CONVENTIONS.asArguments
	}

	var position = "new Position(x = 0, y = 0)"
	var gameboard = Gameboard.getInstance

	@BeforeEach
	def void init() { 
		gameboard.clear
	}

	// Este test solo funciona internamente, no es posible llevarlo a wollok-language
	@ParameterizedTest
	@MethodSource("data")
	def void sayShouldAddBallonMessageToVisualObject(String convention) {
		var message = "A message"
		'''
		«visualObjectWithoutPosition»
		program p {
			var «convention» = «position»
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
