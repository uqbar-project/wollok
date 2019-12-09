package org.uqbar.project.wollok.tests.debugger

import org.uqbar.project.wollok.tests.debugger.util.AbstractXDebuggerImplTestCase
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Disabled

/**
 * Tests step into implementation of the debugger
 * 
 * @author jfernandes
 */
class StepIntoDebugTestCase extends AbstractXDebuggerImplTestCase {
	
	@Disabled
	@Test
	def void stepByStepEvaluationSummingTwoNumbers() {
		'''
		program a {
			const one = 1
			const two = 2
			const sum = one + two
		}'''.debugSteppingInto [
			expect = #[
					program,
					program,
					"const one = 1",
					"const two = 2",
					"const sum = one + two",
					"one"
			]
		]
	}
	
	@Disabled
	@Test
	def void stepByStepEvaluationWithAForEach() {
		'''
		program a {
			const strings = [1, 2, 3]
			var sum = 0
			strings.forEach { s =>
				sum += s
			}
			assert.equals(6, sum)
		}'''.debugSteppingInto [
			expect = #[
					program,
					program,
					"const strings = [1, 2, 3]",
					"var sum = 0",
					'''
					strings.forEach { s =>
							sum += s
						}''',
					'''
					{ s =>
							sum += s
						}''',
					"assert.equals(6, sum)",
					"sum"
			]
		]
	}
	
}