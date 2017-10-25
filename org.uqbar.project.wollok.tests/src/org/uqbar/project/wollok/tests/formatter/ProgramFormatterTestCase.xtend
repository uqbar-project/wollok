package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
class ProgramFormatterTestCase extends AbstractWollokFormatterTestCase {

	@Test
	def void testSimpleProgramWithVariablesAndMessageSend() throws Exception {
		assertFormatting('''program p { const a = 10 const b = 20 self.println(a + b) }''', '''
		program p {
			const a = 10
			const b = 20
			self.println(a + b)
		}
		''')
	}

}