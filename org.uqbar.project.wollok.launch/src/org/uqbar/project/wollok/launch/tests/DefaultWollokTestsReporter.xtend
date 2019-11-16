package org.uqbar.project.wollok.launch.tests

import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

/**
 * Default implementation
 * Measures performance between tests, a group of tests and overall process
 * 
 * @author tesonep
 * @author dodain   Adding time elapsed for each test
 */
@Accessors
class DefaultWollokTestsReporter implements WollokTestsReporter {
	// Attributes for carrying a folder test run
	String folder
	boolean processingManyFiles
	long folderStartTime
	long folderTimeElapsedInMilliseconds

	// Total time of group of tests run
	long groupStartTime
	long groupTimeElapsedInMilliseconds	
	
	// Total time of all tests run
	long overallStartTime
	long overallTimeElapsedInMilliseconds	
	
	Map<WTest,TimeDuration> testTimeElapsed = newHashMap
		
	/**
	 * Global events - starting & finishing the whole execution
	 */	
	override started() {
		this.overallStartTime = System.currentTimeMillis
	}
	
	override finished() {
		overallTimeElapsedInMilliseconds = System.currentTimeMillis - overallStartTime
	}
	
	/** starting & finishing execution of a certain folder, a group of files */
	override folderStarted(String folder) {
		this.processingManyFiles = folder !== null && !folder.equals("")
		this.folder = folder
		this.folderStartTime = System.currentTimeMillis
	}
	
	override folderFinished() {
		this.processingManyFiles = false
		folderTimeElapsedInMilliseconds = System.currentTimeMillis - this.folderStartTime
	}
	
	/** starting & finishing a group of tests */
	override groupStarted(String groupName) {
		this.groupStartTime = System.currentTimeMillis
	}
	
	override groupFinished(String groupName) {
		this.groupTimeElapsedInMilliseconds = System.currentTimeMillis - groupStartTime
	}
	
	/** starting & finishing execution of a single test */
	override testStarted(WTest test) {
		testTimeElapsed.put(test, new TimeDuration(System.currentTimeMillis))
	}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		throw assertionError
	}
	
	override reportTestOk(WTest test) {}
	
	override testsToRun(String suiteName, WFile file, List<WTest> tests) {}
	
	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		throw exception
	}
	
	def testFinished(WTest test) {
		if (test.hasTimeElapsedRecord) {
			testTimeElapsed.get(test).to = System.currentTimeMillis
		}
	}
	
	def getTotalTime(WTest test) {
		if (test.hasTimeElapsedRecord) testTimeElapsed.get(test).totalTime else 0
	}
	
	/**
	 * If there was an error in the fixture, or in variable initialization, we won't be able to get the test in the map
	 */
	def hasTimeElapsedRecord(WTest test) {
		testTimeElapsed.get(test) !== null
	}
}

@Accessors
class TimeDuration {
	long from
	long to
	
	new(long from) {
		this.from = from
	}
	
	def totalTime() {
		to - from
	}
}