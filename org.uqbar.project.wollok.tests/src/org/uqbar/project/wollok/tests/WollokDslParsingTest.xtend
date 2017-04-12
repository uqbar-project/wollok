package org.uqbar.project.wollok.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * This test is not adding anything. However, we have to keep it because Xtext generates it as an example, if it does not find it.
 * I have added an stupid program just to check it, and make Xtext happy.
 * 
 * @author tesonep
 */
@RunWith(XtextRunner)
@InjectWith(WollokDslInjectorProvider)
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
		Assert.assertNotNull(result)
		Assert.assertTrue(result.eResource.errors.isEmpty)
	}
}
