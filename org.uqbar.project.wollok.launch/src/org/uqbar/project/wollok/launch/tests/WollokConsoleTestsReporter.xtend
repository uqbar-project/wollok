package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

class WollokConsoleTestsReporter implements WollokTestsReporter {
	
	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		println('''Test: «test.name» : «assertionError.message» («resource»:«lineNumber»)''')
	}
	
	override reportTestOk(WTest test) {
		println('''Test: «test.name» : Ok''')
	}
	
	override testsToRun(List<WTest> tests) {
		println('''Tests to run: «tests.join(", ")»''')
	}
	
	override testStart(WTest test) {
		println('''Starting test: «test.name»''')
	}
	
}