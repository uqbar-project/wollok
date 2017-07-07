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
	
	@Test
	def void replaceSpecialCharactersAtBeginningAndSpace() {
		val result = " [m4.2".deleteAnsiCharacters
		Assert.assertEquals(" 4.2", result)
	}

	@Test
	def void replaceSpecialCharactersAtBeginning() {
		val result = "[m4.2".deleteAnsiCharacters
		Assert.assertEquals("4.2", result)
	}
	
	@Test
	def void replaceSpecialCharactersAtBeginningAndSeveralTimes() {
		val result = "[m4.[m2[m".deleteAnsiCharacters
		Assert.assertEquals("4.2", result)
	}
}
