package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

/**
 * Logs the events to the console output.
 * Used when running the tests from console without a remote client program (RMI)
 * like eclipse UI.
 * 
 * @author tesonep
 */
class WollokConsoleTestsReporter implements WollokTestsReporter {
	
	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		println('''Test: «test.name» : «assertionError.message» («resource.trimFragment»:«lineNumber»)''')
	}
	
	override reportTestOk(WTest test) {
		println('''Test: «test.name» : Ok''')
	}
	
	override testsToRun(WFile file, List<WTest> tests) {}
	override testStart(WTest test) {}
	
	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		println('''Test: «test.name» : «exception.message» («resource.trimFragment»:«lineNumber»)''')
	}
	
}