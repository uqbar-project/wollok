package org.uqbar.project.wollok.launch.tests

import java.util.List

/**
 * @author tesonep
 */
interface WollokRemoteUITestNotifier {
	
	def void assertError(String testName, String messaage, StackTraceElementDTO[] stackTrace, int lineNumber, String resource)
	
	def void testOk(String testName)
	
	def void testsToRun(String containerResource, List<WollokTestInfo> tests)
	
	def void testStart(String testName)
	
	def void error(String testName, String exceptionAsString, StackTraceElementDTO[] stackTrace, int lineNumber, String resource)
	
	def void testsResult(List<WollokResultTestDTO> resultTests)

}
