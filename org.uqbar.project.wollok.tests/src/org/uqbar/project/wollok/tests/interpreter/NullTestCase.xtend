package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class NullTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void messageSentToNull() {
		'''
		assert.throwsException({ null.sayHi() })
		assert.throwsException({ null.toString() })
		'''.test
	}

	@Test
	def void numberOperatorsSentToNull() {
		'''
		assert.throwsException({ null + 3 })
		assert.throwsException({ null - 3 })
		assert.throwsException({ null * 3 })
		assert.throwsException({ null / 3 })
		'''.test
	}
	
	@Test
	def void booleanOperatorsSentToNull() {
		'''
		assert.throwsException({ null || true })
		assert.throwsException({ null && true })
		'''.test
	}
	
	@Test
	def void equalEqualOperatorSentToNull() {
		'''
		assert.notThat(null == 8)
		'''.test
	}

	@Test
	def void ifInANullExpression() {
		'''
		var expresionNula
		var mensajeError
		try {
			if (expresionNula) {
				console.println("ooo")
			}
		} catch e: Exception {
			mensajeError = e.getMessage()
		}
		assert.equals("Cannot use null in 'if' expression", mensajeError)
		'''.test
	}
	
}