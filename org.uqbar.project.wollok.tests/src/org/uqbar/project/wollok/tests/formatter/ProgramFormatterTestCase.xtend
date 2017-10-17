package org.uqbar.project.wollok.tests.formatter

import org.junit.Test

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