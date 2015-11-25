package org.uqbar.project.wollok.launch.tests

import java.util.List
import wollok.lib.AssertionException

/**
 * @author tesonep
 */
interface WollokRemoteUITestNotifier {
	
	def void assertError(String testName, AssertionException assertionException, int lineNumber, String resource)
	
	def void testOk(String testName)
	
	def void testsToRun(String containerResource, List<WollokTestInfo> tests)
	
	def void testStart(String testName)
	
	def void error(String testName, String exceptionAsString, int lineNumber, String resource)

}
