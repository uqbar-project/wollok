package org.uqbar.project.wollok.launch.tests

import java.util.List

interface WollokRemoteUITestNotifier {
	def void assertError(String testName, String message, String expected, String actual, int lineNumber,
		String resource)

	def void testOk(String testName)
	def void testsToRun(String containerResource, List<WollokTestInfo> tests)
	def void testStart(String testName)
	def void error(String testName, String message, int lineNumber, String resource)
}
