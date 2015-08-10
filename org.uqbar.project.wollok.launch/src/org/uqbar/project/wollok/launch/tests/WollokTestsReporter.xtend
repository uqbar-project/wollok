package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

interface WollokTestsReporter {
	def void reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource)
	def void reportTestOk(WTest test)
	def void testsToRun(List<WTest> tests)
	def void testStart(WTest test)
}