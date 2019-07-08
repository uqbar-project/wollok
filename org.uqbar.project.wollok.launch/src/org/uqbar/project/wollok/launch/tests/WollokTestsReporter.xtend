package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

/**
 * Wollok interpreter will notify this object about the test
 * execution events.
 * For running it from eclipse UI the implementation will
 * send the events through the wire (RMI) to the UI
 * 
 * @author tesonep
 */
interface WollokTestsReporter {
	def void reportTestAssertError(WTest test, AssertionException wollokException, int lineNumber, URI resource)
	def void reportTestError(WTest test, Exception exception, int lineNumber, URI resource)
	def void reportTestOk(WTest test)
	def void testsToRun(String suiteName, WFile file, List<WTest> tests)
	def void testStart(WTest test)
	
	/**
	 * Tells this reporter that the execution has finished
	 */	
	def void finished(long timeElapsed)
	
	/** Just for processing many files */
	def void initProcessManyFiles(String folder)
	def void endProcessManyFiles()
}