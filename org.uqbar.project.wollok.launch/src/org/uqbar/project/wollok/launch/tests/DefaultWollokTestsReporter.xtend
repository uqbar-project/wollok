package org.uqbar.project.wollok.launch.tests

import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException
import org.eclipse.emf.common.util.URI
import java.util.List

class DefaultWollokTestsReporter implements WollokTestsReporter {
	
	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		throw assertionError
	}
	
	override reportTestOk(WTest test) {}
	
	override testsToRun(List<WTest> tests) {
	}
	
	override testStart(WTest test) {
	}
	
}