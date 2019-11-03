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
 *   folderStarted("folderA")       <== or "several-files" if they are several folders
 *     groupStarted("WFileImpl@489a6d9c")
 *       testToRun("describeA", ...., [test1, test2])
 *       testStarted(test1)
 *       reportTestOk(test1)
 *       testStarted(test2)
 *       reportTestAssertError(test2)
 *     groupFinished("WFileImpl@489a6d9c")
 *     groupStarted("WFileImpl@5b65ac8a")
 *       testToRun("describeB", ...., [test3])
 *       testStarted(test3)
 *       reportTestError(test3)
 *     groupFinished("WFileImpl@5b65ac8a")
 *   folderFinished
 * finished()
 *
 * Potentially we could add several folders, but there's no implemented cycle
 * in WollokLauncherInterpreterEvaluator. 
 * 
 * =================================================================
 * Event lifecycle for a group of tests in a single file
 * 
 * start()
 *   folderStarted(null)                       <== null is passed as folder, single file
 *     groupStarted("WFileImpl@489a6d9c")
 *       testToRun(null, ...., [test1, test2]) <== see null here, no describe
 *       testStarted(test1)
 *       reportTestOk(test1)
 *       testStarted(test2)
 *       reportTestAssertError(test2)
 *     groupFinished("WFileImpl@489a6d9c")
 *   folderFinished 
 * finished()
 *
 *
 * =================================================================
 * Event lifecycle for a single describe in a single file
 * 
 * start()
 *   folderStarted(null)                              <== null is passed as folder, single file
 *     groupStarted("WFileImpl@489a6d9c")
 *       testToRun("describeA", ...., [test1, test2]) <== see "describeA" here
 *       testStarted(test1)
 *       reportTestOk(test1)
 *       testStarted(test2)
 *       reportTestAssertError(test2)
 *     groupFinished("WFileImpl@489a6d9c")
 *   folderFinished
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
	def void folderStarted(String folder)
	def void folderFinished()

	/** starting & finishing a group of tests */
	def void groupStarted(String groupName)
	def void groupFinished(String groupName)
	
	/** predefining which tests are going to run */
	def void testsToRun(String suiteName, WFile file, List<WTest> tests)
	
	
	def void testsToRun(List<String> fathersPath, String suiteName, WFile file, List<WTest> tests)

	/** starting & finishing execution of a single test */
	def void testStarted(WTest test)
	def void reportTestOk(WTest test)
	def void reportTestAssertError(WTest test, AssertionException wollokException, int lineNumber, URI resource)
	def void reportTestError(WTest test, Exception exception, int lineNumber, URI resource)
	

}