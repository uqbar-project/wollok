package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.uqbar.project.wollok.errorHandling.StackTraceElementDTO

/**
 * @author tesonep
 */
interface WollokRemoteUITestNotifier {
			
	def void testsToRun(String suiteName, String containerResource, List<WollokTestInfo> tests, boolean processingManyFiles)
			
	def void testsResult(List<WollokResultTestDTO> resultTests, long millisecondsElapsed)

	def void showFailuresAndErrorsOnly(boolean showFailuresAndErrors)
	
	def void start()
		
}
