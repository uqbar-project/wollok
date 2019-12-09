package org.uqbar.project.wollok.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider
import org.uqbar.project.wollok.wollokDsl.WFile

import static org.junit.jupiter.api.Assertions.*
import org.eclipse.xtext.testing.extensions.InjectionExtension

/**
 * This test is not adding anything. However, we have to keep it because Xtext generates it as an example, if it does not find it.
 * I have added an stupid program just to check it, and make Xtext happy.
 * 
 * @author tesonep
 */
@ExtendWith(InjectionExtension)
@InjectWith(WollokTestInjectorProvider)
class WollokDslParsingTest {
	@Inject
	ParseHelper<WFile> parseHelper

	@Test
	def void loadModel() {
		val result = parseHelper.parse('''
			program aTest {
				assert.that(1+1 > 1)
			}
		''')
		assertNotNull(result)
		assertTrue(result.eResource.errors.isEmpty)
	}
}
