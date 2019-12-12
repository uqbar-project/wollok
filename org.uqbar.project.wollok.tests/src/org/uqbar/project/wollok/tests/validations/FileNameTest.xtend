package org.uqbar.project.wollok.tests.validations

import com.google.inject.Inject
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.uqbar.project.wollok.tests.WollokDslInjectorProvider
import org.uqbar.project.wollok.tests.interpreter.WollokParseHelper
import org.uqbar.project.wollok.validation.WollokDslValidator

@ExtendWith(InjectionExtension)
@InjectWith(WollokDslInjectorProvider)
class FileNameTest {
	@Inject	WollokParseHelper parseHelper
	@Inject XtextResourceSet resourceSet
	@Inject protected extension ValidationTestHelper

	@Test
	def void testValidName() {
		val files = "model" -> '''
			class Tren {}
		'''
		var result = parseHelper.parse(files, resourceSet)
		val errors = result.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: «errors.join(", ")»''')
	}

	@Test
	def void testNameWithSpaces() {
		val files = "mo  del" -> '''
			class Tren {}
		'''

		var errors = parseHelper.parse(files, resourceSet).validate
		Assertions.assertEquals(errors.head.code, WollokDslValidator.INVALID_NAME_FOR_FILE)
	}

	@Test
	def void testNameWithDashes() {
		val files = "mo-del" -> '''
			class Tren {}
		'''

		var errors = parseHelper.parse(files, resourceSet).validate
		Assertions.assertEquals(errors.head.code, WollokDslValidator.INVALID_NAME_FOR_FILE)
	}

	@Test
	def void testNameWithOnlyNumbers() {
		val files = "1234a" -> '''
			class Tren {}
		'''

		var errors = parseHelper.parse(files, resourceSet).validate
		Assertions.assertEquals(errors.head.code, WollokDslValidator.INVALID_NAME_FOR_FILE)
	}

}
