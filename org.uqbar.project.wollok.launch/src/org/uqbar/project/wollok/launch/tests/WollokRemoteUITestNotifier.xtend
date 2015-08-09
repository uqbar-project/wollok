package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI

interface WollokRemoteUITestNotifier {
	def void assertError(String testName, String message, String expected, String actual, int lineNumber, String resource)

	def void testOk(String testName)

	def void testsToRun(List<String> testNames)

	def void testStart(String testName)

}
