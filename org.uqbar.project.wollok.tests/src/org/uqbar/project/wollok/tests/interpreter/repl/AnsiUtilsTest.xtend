package org.uqbar.project.wollok.tests.interpreter.repl

import org.junit.Assert
import org.junit.Test

import static extension org.uqbar.project.wollok.ui.console.highlight.AnsiUtils.*

class AnsiUtilsTest {
	
	@Test
	def void replaceSpecialCharacters() {
		val result = "[36m>>> [m4.2".deleteAnsiCharacters
		Assert.assertEquals(">>> 4.2", result)
	}
	
}
