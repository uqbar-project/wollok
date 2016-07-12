package org.uqbar.project.wollok.tests.interpreter.flow

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author jfernandes
 */
class WhileTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void defaultConstructor() {
		'''
		program t {
			var i = 0
			var sum = 0
			while(i < 10) {
				sum += i
				i++
			}
			assert.equals(i,10)
			assert.equals(sum, 45)
		}
		'''.interpretPropagatingErrors
	}
	
}