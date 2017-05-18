package org.uqbar.project.wollok.tests.validations

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.validation.WollokDslValidator

class FileNameTest extends AbstractWollokInterpreterTestCase {
	@Test
	def void testValidName() {
		val files = "model" -> '''
			class Tren {}
		'''

		val model = parse(files, resourceSet)
		model.assertNoErrors
	}

	@Test
	def void testNameWithSpaces() {
		val files = "mo  del" -> '''
			class Tren {}
		'''

		val model = parse(files, resourceSet)
		model.assertError(model.eClass, WollokDslValidator.INVALID_NAME_FOR_FILE)
	}

	@Test
	def void testNameWithDashes() {
		val files = "mo-del" -> '''
			class Tren {}
		'''

		val model = parse(files, resourceSet)
		model.assertError(model.eClass, WollokDslValidator.INVALID_NAME_FOR_FILE)
	}

	@Test
	def void testNameWithOnlyNumbers() {
		val files = "1234a" -> '''
			class Tren {}
		'''

		val model = parse(files, resourceSet)
		model.assertError(model.eClass, WollokDslValidator.INVALID_NAME_FOR_FILE)
	}

}
