package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

class WollokConsoleTestsReporter implements WollokTestsReporter {
	
	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		println('''Test: «test.name» : «assertionError.message» («resource.trimFragment»:«lineNumber»)''')
	}
	
	override reportTestOk(WTest test) {
		println('''Test: «test.name» : Ok''')
	}
	
	override testsToRun(WFile file, List<WTest> tests) {}
	override testStart(WTest test) {}
	
	override reportTestError(WTest test, WollokInterpreterException exception, int lineNumber, URI resource) {
		println('''Test: «test.name» : «exception.message» («resource.trimFragment»:«lineNumber»)''')
	}
	
}