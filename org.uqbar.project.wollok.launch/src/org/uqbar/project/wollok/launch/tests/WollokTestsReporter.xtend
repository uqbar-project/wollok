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
 * @author dodain    Adding documentation
 * 
 * =================================================================
 * Event lifecycle for several files
 * 
 * start()
 *   initProcessManyFiles("folderA")
 *     testToRun("describeA", ...., [test1, test2], true)
 *     testStarted(test1)
 *     reportTestOk(test1)
 *     testStarted(test2)
 *     reportTestAssertError(test2)
 *   endProcessManyFiles 
 *   initProcessManyFiles("folderB")
 *     testToRun("describeB", ...., [test3], true)
 *     testStarted(test3)
 *     reportTestError(test3)
 *   endProcessManyFiles 
 * finished()
 * 
 * 
 * =================================================================
 * Event lifecycle for a group of tests in a single file
 * 
 * start()
 *   initProcessManyFiles("") 
 *     testToRun(null, ...., [test1, test2], true)
 *     testStarted(test1)
 *     reportTestOk(test1)
 *     testStarted(test2)
 *     reportTestAssertError(test2)
 *   endProcessManyFiles 
 * finished()
 *
 *
 * =================================================================
 * Event lifecycle for a describe in a single file
 * 
 * start()
 *   initProcessManyFiles("") 
 *     testToRun("describeA", ...., [test1, test2], true)
 *     testStarted(test1)
 *     reportTestOk(test1)
 *     testStarted(test2)
 *     reportTestAssertError(test2)
 *   endProcessManyFiles 
 * finished()
 * 
 */
interface WollokTestsReporter {

	/**
	 * Global events - starting & finishing the whole execution
	 */	
	def void started()
	def void finished()
	
	/** starting & finishing execution of a certain folder, a group of files */
	def void initProcessManyFiles(String folder)
	def void endProcessManyFiles()

	/** predefining which tests are going to run - when changing a folder reset should be true */
	def void testsToRun(String suiteName, WFile file, List<WTest> tests, boolean reset)

	/** starting & finishing execution of a single test */
	def void testStarted(WTest test)
	def void reportTestOk(WTest test)
	def void reportTestAssertError(WTest test, AssertionException wollokException, int lineNumber, URI resource)
	def void reportTestError(WTest test, Exception exception, int lineNumber, URI resource)
	

}