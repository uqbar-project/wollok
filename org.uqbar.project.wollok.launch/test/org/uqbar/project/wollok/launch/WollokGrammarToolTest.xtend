package org.uqbar.project.wollok.launch

import org.junit.Test

import static org.uqbar.project.wollok.launch.WollokGrammarPrinter.*

import static extension org.junit.Assert.*

/**
 * @author jfernandes
 */
class WollokGrammarToolTest {
	
	@Test
	def testEscapeAsterisk() {
		"\\*".assertEquals(jsonRegexpEscaping("*"))
		"\\*=".assertEquals(jsonRegexpEscaping("*="))
	}
	
	@Test
	def testOperatorsEscaping() {
		val original = #["===", "&&", "*=", "..", "**", "#", "!", "%", "*", "?:", "+", "(", ")", ".", "/", ",", "+=", "-", "..<", "!==", ";", ":", "/=", "?.", "++", ">", "=", "<", ">=", "=>", "==", "]", "[", "-=", "->", "|", "--", "<>", "!=", "%=", "}", "|", "{"]
		val expected = "===|&&|\\*=|\\.\\.|\\*\\*|#|!|%|\\*|\\?:|\\+|\\(|\\)|\\.|\\/|,|\\+=|\\-|\\.\\.<|!==|;|:|\\/=|\\?\\.|\\+\\+|>|=|<|>=|=>|==|\\]|\\[|\\-=|\\->|\\||\\-\\-|<>|!=|%=|}|\\||{"
		
		assertEquals(expected, getOperators(original))
	}
	
}