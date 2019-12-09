package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@ExtendWith(InjectionExtension)
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