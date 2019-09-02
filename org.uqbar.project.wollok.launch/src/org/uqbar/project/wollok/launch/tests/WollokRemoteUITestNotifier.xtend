package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.uqbar.project.wollok.errorHandling.StackTraceElementDTO
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * @author tesonep
 */
interface WollokRemoteUITestNotifier {
	
	def void assertError(String testName, String message, StackTraceElementDTO[] stackTrace, int lineNumber, String resource)
	
	def void testOk(String testName)
	
	def void testsToRun(String suiteName, String containerResource, List<WollokTestInfo> tests, boolean processingManyFiles)
	
	def void testStart(String testName)
	
	def void error(String testName, String exceptionAsString, StackTraceElementDTO[] stackTrace, int lineNumber, String resource)
	
	def void testsResult(List<WollokResultTestDTO> resultTests, long millisecondsElapsed)

	def void showFailuresAndErrorsOnly(boolean showFailuresAndErrors)
	
	def void start()
	
}
