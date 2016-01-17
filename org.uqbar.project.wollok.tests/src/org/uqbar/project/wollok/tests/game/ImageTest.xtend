package org.uqbar.project.wollok.tests.game

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import wollok.lib.WImage

class ImageTest  extends AbstractWollokInterpreterTestCase {

	val conventions = WImage.CONVENTIONS

	@Test
	def void canInstancePosition() {
		'''
			program p {
				var p = new Position(0,0)
			}'''.interpretPropagatingErrors
	}
}