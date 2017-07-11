package org.uqbar.project.wollok.tests.natives

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test

/**
 * @author jfernandes
 */
// TODO: this could have more tests, with more complex cases :P
class ExceptionPropagationInNativeTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void nativeMethodCallsWollokClosureThrowingASimpleException() {
		#["natives"->'''
class Repeater {
	method ntimes(n, closure) native
}

program natives {
	const repeater = new Repeater()

	const closure = { throw new Exception("SoundGarden") }
	try {
		repeater.ntimes(1, closure)
	}
	catch e {
		assert.equals(
"wollok.lang.Exception: SoundGarden
	at  [/natives.wpgm:8]
	at natives.Repeater.ntimes(n,closure) [/natives.wpgm:2]
	at  [/natives.wpgm:10]
",e.getStackTraceAsString())
	} 
}
		''']
		.interpretPropagatingErrors
	}
	
}